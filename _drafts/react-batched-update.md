---
layout: post
title: "Understanding React.js (Part 2) - Batched Updates"
author: "Gaoping Huang"
tags: [JavaScript, React]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---

In React, we can update the states of class components via `setState()` and update states of function components via hooks (i.e., `useState()`). These changes cause parts of the component tree to re-render. A naïve mechanism would be to re-render the component on every call of `setState()`, which would be inefficient when there are multiple calls of `setState()` inside a React **event handler** or **synchronous lifecycle method**. 

<!-- 手动为一段或多段添加分隔符。这样才能正确的转换成 `post.excerpts`。 -->
<!--more-->

React implements a batched updating mechanism to reduce the number of component renders. Consequently, multiple state changes will be batched into a single update, which will eventually trigger one re-render of a component.

There are existing great articles on this topic:
1. [React State Batch Update](https://medium.com/swlh/react-state-batch-update-b1b61bd28cd2) by Nitai Ahroni. This article does not focus on the source code of React, but rather from the App developer's perspective using examples.
2. [Understanding The React Source Code - UI Updating (Transactions) VI](https://holmeshe.me/understanding-react-js-source-code-initial-rendering-VI/) and [VII](https://holmeshe.me/understanding-react-js-source-code-initial-rendering-VII/) by Holmes He. These two articles explain the source code of batched updates and transactions in great details. 

Given that Holmes He has already done a great work explaining many technical details, here I will only mention some parts that I feel interesting. Note that the source code is from an old version of React (v15+). The Fiber reconciler of React v16+ is using a different mechanism, which I will cover in the future. 

## ReactUpdateQueue

React implements a batched updating mechanism for several scenarios, such as changing states via `setState()` within life cycles, re-rendering component tree within a container, and calling callbacks.  Here, let's ignore the `useState()` hooks because it is not part of V15+.

When `setState()` is called, it is delegated to `this.updater.enqueueSetState()`. As mentioned in the [previous post](https://gaopinghuang0.github.io/2020/12/15/react-architecture-and-injection), `this.updater` will be injected by a specific renderer. For example, if the renderer `ReactDOM` is used, it injects `ReactUpdateQueue` as `this.updater`. 

Next, we look at the code for `ReactUpdateQueue.enqueueSetState()`:

```js
var ReactUpdateQueue = {
  ...
  enqueueSetState: function(publicInstance, partialState) {
    var internalInstance = getInternalInstanceReadyForUpdate(
      publicInstance,
      'setState',
    );

    if (!internalInstance) {
      return;
    }

    var queue =
      internalInstance._pendingStateQueue ||
      (internalInstance._pendingStateQueue = []);
    queue.push(partialState);

    enqueueUpdate(internalInstance);
  },
  ...
}

// src/renderers/shared/stack/reconciler/ReactUpdateQueue.js
```
React maintains a map from public instances (e.g., instances of class components) to internal instances (e.g., instances of internal components). The code above first retrieves the internal instance from the map by the public instance, then appends the new (partial) state to  `_pendingStateQueue` of the internal instance.  Finally, it calls `enqueueUpdate()` that essentially calls `ReactUpdates.enqueueUpdate()`.

Similarly, if a callback is specified in `setState()`, it will be enqueued by `this.updater.enqueueCallback()`. Subsequently, this callback will be appended to `_pendingCallbacks` of the internal instance. Lastly, `enqueueUpdate()` is called.

If we call `ReactDOM.render()` for the first time, the whole component tree will be mounted onto the root container. If we call `ReactDOM.render()` again with a new element, the component tree will be updated. Specifically, `ReactUpdateQueue.enqueueElementInternal()` is called to set new element as `_pendingElement` of the internal instance. Again, `enqueueUpdate()` is called.

In summary, `ReactUpdateQueue` is a middle layer that caches the new state/element to an internal field of the internal instance (e.g., `_pendingStateQueue`, `_pendingElement`, etc).  Then it calls `ReactUpdates.enqueueUpdate()` to start the actual batch updating. If any of those internal fields are not null, it means that the component is *dirty*, which needs a re-render. Once a component is re-rendered, those internal fields will be reset to `null` to avoid further re-rendering.

### ReactUpdates and Transactions
Now, we look at `ReactUpdates.enqueueUpdate()`:

```js
function enqueueUpdate(component) {
  ensureInjected();

  if (!batchingStrategy.isBatchingUpdates) {
    batchingStrategy.batchedUpdates(enqueueUpdate, component);
    return;
  }

  dirtyComponents.push(component);
  if (component._updateBatchNumber == null) {
    component._updateBatchNumber = updateBatchNumber + 1;
  }
}

// src/renderers/shared/stack/reconciler/ReactUpdates.js
```
The call stack is as follows:

1) `ReactDefaultBatchingStrategy` is injected as `batchingStrategy`, as seen in [previous post](https://gaopinghuang0.github.io/2020/12/15/react-architecture-and-injection);

2)  When `enqueueUpdate()` is called the first time, `ReactDefaultBatchingStrategy.isBatchingUpdates` is false, which calls `ReactDefaultBatchingStrategy.batchedUpdates()`. The code is below:

```js
var ReactDefaultBatchingStrategy = {
  isBatchingUpdates: false,

  batchedUpdates: function(callback, a, b, c, d, e) {
    var alreadyBatchingUpdates = ReactDefaultBatchingStrategy.isBatchingUpdates;

    ReactDefaultBatchingStrategy.isBatchingUpdates = true;

    // The code is written this way to avoid extra allocations
    if (alreadyBatchingUpdates) {
      return callback(a, b, c, d, e);
    } else {
      return transaction.perform(callback, null, a, b, c, d, e);
    }
  },
};

// src/renderers/shared/stack/reconciler/ReactDefaultBatchingStrategy.js
```

3) `batchedUpdates()` sets `ReactDefaultBatchingStrategy.isBatchingUpdates` to true, and calls `transaction.perform()`. The `callback` argument passed into `perform()` is `enqueueUpdate()` above. Note that in future calls of `batchedUpdates`, the `callback` will be called directly so that `transaction.perform()` is guaranteed to be called for only once. However, we usually call `enqueueUpdate()` directly, which will not call `batchedUpdates()` for the second time. This means we normally will not reach the true branch of `batchedUpdates()`. But this is added as [defensive programming](https://en.wikipedia.org/wiki/Defensive_programming).

4) In general, the default `Transaction.perform()` will first initiate all the defined wrappers (i.e., `Transaction.initializeAll()`), then call the `callback`, and finally close all the wrappers (i.e., `Transaction.closeAll()`). The exception handling here is interesting. A `try-finally` block is used within a `for-loop` rather than `try-catch`. Take `initializeAll()` as an example. If the i-th wrapper fails to initialize and throws an exception, it breaks the `for-loop`, but the `finally` block will continue to initialize the `i+1`-th wrapper till the last wrapper. Handling the exception in this way is because `try-catch` makes debugging more difficult.

5) In this case, the `transaction` here is `ReactDefaultBatchingStrategyTransaction`, which is a subclass of `Transaction` and has two wrappers (`FLUSH_BATCHED_UPDATES` and `RESET_BATCHED_UPDATES`). Initializing these two wrappers does nothing because they have `emptyFunction` as `initialize()`.

6) Within the context of `transaction` while `ReactDefaultBatchingStrategy.isBatchingUpdates` being true, `enqueueUpdate()` is called for the second time. Then, the component will be saved into `dirtyComponents`.

```js
  ...
  dirtyComponents.push(component);
  ...
```

7) When `enqueueUpdate()` returns, `transaction` starts to close up all the wrappers. The `close()` of the first wrapper `FLUSH_BATCHED_UPDATES` is called. This method further calls `ReactUpdates.flushBatchedUpdates()`, which is the method that actually handles all the updates.

```js
var flushBatchedUpdates = function () {
  while (dirtyComponents.length || asapEnqueued) {
    if (dirtyComponents.length) {
      var transaction = ReactUpdatesFlushTransaction.getPooled();
      transaction.perform(runBatchedUpdates, null, transaction);
      ReactUpdatesFlushTransaction.release(transaction);
    }
   ...
  }
};

// src/renderers/shared/stack/reconciler/ReactUpdates.js
```

8) `ReactUpdatesFlushTransaction` is initialized and calls `runBatchedUpdates()` within this transaction.  We can see that an instance of `ReactUpdatesFlushTransaction` is obtained from a pool via `getPooled()`, and then is put back to the pool via `release()` after usage. These two methods come from `PooledClass`. However, there is a [discussion on GitHub about removing this class](https://github.com/facebook/react/issues/9325). It seems that the previous concerns about the deoptimization of `auguments` has been resolved by modern JS engine. Therefore, we can ignore this class.

9) `ReactUpdatesFlushTransaction` is also a subclass of `Transaction` but overrides the `perform()` method which will actually call `ReactReconcileTransaction.perform()`. In this way, it first initializes the wrappers of `ReactUpdatesFlushTransaction` and further initializes the wrappers of `ReactReconcileTransaction`.

```js
var NESTED_UPDATES = {
  initialize: function() {
    this.dirtyComponentsLength = dirtyComponents.length;
  },
  close: function() {
    if (this.dirtyComponentsLength !== dirtyComponents.length) {
      dirtyComponents.splice(0, this.dirtyComponentsLength);
      flushBatchedUpdates();      // scr: ----------------------> a)
    } else {
      dirtyComponents.length = 0; // scr: ----------------------> b)
    }
  },
};

var UPDATE_QUEUEING = { // scr: ------> we omit this wrapper for now
  initialize: function() {
    this.callbackQueue.reset();
  },
  close: function() {
    this.callbackQueue.notifyAll();
  },
};

// Wrappers for ReactUpdatesFlushTransaction
var TRANSACTION_WRAPPERS = [NESTED_UPDATES, UPDATE_QUEUEING];

// src/renderers/shared/stack/reconciler/ReactUpdates.js
```

10)  In `initialize()` of the `NESTED_UPDATES` wrapper of `ReactUpdatesFlushTransaction`, the current number of `dirtyComponents` is stored. Also, the `this.callbackQueue` is reset in `UPDATE_QUEUEING`. Then `ReactUpdates.runBatchedUpdates()` is called within the nested transaction `ReactReconcileTransaction`. 

```js
function ReactReconcileTransaction(useCreateElement: boolean) {
  this.reinitializeTransaction();
  // Only server-side rendering really needs this option (see
  // `ReactServerRendering`), but server-side uses
  // `ReactServerRenderingTransaction` instead. This option is here so that it's
  // accessible and defaults to false when `ReactDOMComponent` and
  // `ReactDOMTextComponent` checks it in `mountComponent`.`
  this.renderToStaticMarkup = false;
  this.reactMountReady = CallbackQueue.getPooled(null);
  this.useCreateElement = useCreateElement;
}
```

11)  The wrappers of `ReactReconcileTransaction` are mostly related to the event and selection in browser.  We can ignore them. 
 
12) However, inside the constructor of `ReactReconcileTransaction`, we find that the 

13) In `close()` method of the `NESTED_UPDATES` wrapper, the stored number is compared to the latest number of `dirtyComponents`. If they are different, `flushBatchedUpdates()` is called again. Note that the two transactions (`ReactUpdatesFlushTransaction` and `ReactReconcileTransaction`) are initialized again, similar to step 8) and 9).  

14) Also note that the `close()` of `UPDATE_QUEUEING` wrapper of `ReactUpdatesFlushTransaction` has not been called. It means that it is still in transaction. Essentially, `this.callbackQueue` is `reset()`. **It seems that there may be some callbacks that have never been triggered but cleared!**  *(I will come back later about this issue.)*

???) Lastly, the `close()` of the wrapper `RESET_BATCHED_UPDATES` is called, which sets `ReactDefaultBatchingStrategy.isBatchingUpdates` back to false and completes the circle.

It is important to note that any successive calls of `enqueueUpdate()` between 3) and ???) are supposed to be executed in the context of `ReactDefaultBatchingStrategy.isBatchingUpdates:true`. If any additional updates occur during this period (e.g., by `componentDidUpdate` or similar), those components will be pushed to `dirtyComponents` as well. So, it's like
```js
dirtyComponents.push(component);   // 6)
ReactUpdates.flushBatchedUpdates()  // 7)
// Some additional updates occur
dirtyComponents.push(component);   // 6)
dirtyComponents.push(component);   // 6)
dirtyComponents.push(component);   // 6)
...
ReactUpdates.flushBatchedUpdates()  // 7)

// No further updates
ReactDefaultBatchingStrategy.isBatchingUpdates = false    // ????)
```

### ReactCurrentOwner and Callbacks
renderSubtreeIntoContainer
      ReactCurrentOwner.current = this;  <-- global variable. In ReactCompositeComponent  _renderComponent, set `this` as owner. If owner is not null, that means we are inside the render of a Component. We should not enqueue callback or setState if we are in the middle of render. For example, `getInternalInstanceReadyForUpdate` will check owner.

in runBatchedUpdates, stash callbacks until next render. The callbacks added to each dirty component will be moved into CallbackQueue. 
Other callbacks will be put into CallbackQueue directly, such as didMount, didUpdate, via `getReactMountReady().enqueue()` ==> `CallbackQueue.enqueue()`. The order will be children first, parent next.

All callbacks in CallbackQueue will be invoked after the updates. Double check if it is before resetting isBatchingUpdate to false or after.  If it is before and the callback calls setState, what will happen?



