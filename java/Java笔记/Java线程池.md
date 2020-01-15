# Java线程池

## 一 线程池基本概念

> 线程池，本质上是一种对象池，用于管理线程资源。
> 在任务执行前，需要从线程池中拿出线程来执行。
> 在任务执行完成之后，需要把线程放回线程池。
> 通过线程的这种反复利用机制，可以有效地避免直接创建线程所带来的坏处。

## 二线程池的好处

> 1. 降低资源的消耗。线程本身是一种资源，创建和销毁线程会有CPU开销；创建的线程也会占用一定的内存。
> 2. 提高任务执行的响应速度。任务执行时，可以不必等到线程创建完之后再执行。
> 3. 提高线程的可管理性。线程不能无限制地创建，需要进行统一的分配、调优和监控。

## 三线程池核心实现类

> ```java
> public ThreadPoolExecutor(int corePoolSize,
>                           int maximumPoolSize,
>                           long keepAliveTime,
>                           TimeUnit unit,
>                           BlockingQueue<Runnable> workQueue,
>                           ThreadFactory threadFactory,
>                           RejectedExecutionHandler handler);
> ```
>
> corePoolSize: 线程池核心线程数
>
> maximumPoolSize: 线程池最大线程数
>
> keepAliveTime , unit: 保活时间单位为unit
>
> workQueue : 待处理的任务队列
>
> handler : 拒接策略

## 四线程池工具类

> Executors
>
> ```java
> // 创建单一线程的线程池
> public static ExecutorService newSingleThreadExecutor();
> 
> public static ExecutorService newSingleThreadExecutor() {
>         return new FinalizableDelegatedExecutorService
>             (new ThreadPoolExecutor(1, 1,
>                                     0L, TimeUnit.MILLISECONDS,
>                                     new LinkedBlockingQueue<Runnable>()));
>     }
> 
> 
> 
> // 创建固定数量的线程池
> public static ExecutorService newFixedThreadPool(int nThreads);
> 
> public static ExecutorService newFixedThreadPool(int nThreads) {
>         return new ThreadPoolExecutor(nThreads, nThreads,
>                                       0L, TimeUnit.MILLISECONDS,
>                                       new LinkedBlockingQueue<Runnable>());
> 	}
> 
> 
> 
> 
> // 创建带缓存的线程池
> public static ExecutorService newCachedThreadPool();
> 
> public static ExecutorService newCachedThreadPool() {
>         return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
>                                       60L, TimeUnit.SECONDS,
>                                       new SynchronousQueue<Runnable>());
>     }
> 
> 
> // 创建定时调度的线程池
> public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize);
> 
> public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
>         return new ScheduledThreadPoolExecutor(corePoolSize);
>     }
> 
> 
> // 创建流式（fork-join）线程池
> public static ExecutorService newWorkStealingPool();
> 
> public static ExecutorService newWorkStealingPool() {
>         return new ForkJoinPool
>             (Runtime.getRuntime().availableProcessors(),
>              ForkJoinPool.defaultForkJoinWorkerThreadFactory,
>              null, true);
>     }
> ```

## 五拒接策略

> 所谓拒绝策略，就是当线程池满了、队列也满了的时候，我们对任务采取的措施。或者丢弃、或者执行、或者其他...
>
> jdk自带的拒接策略
>
> 1.  `CallerRunsPolicy` // 在调用者线程执行
> 2.  `AbortPolicy` // 直接抛出`RejectedExecutionException`异常
> 3.  `DiscardPolicy` // 任务直接丢弃，不做任何处理
> 4.  `DiscardOldestPolicy` // 丢弃队列里最旧的那个任务，再尝试执行当前任务
>
> 这四种策略各有优劣，比较常用的是`DiscardPolicy`，但是这种策略有一个弊端就是任务执行的轨迹不会被记录下来。所以，我们往往需要实现自定义的拒绝策略， 通过实现`RejectedExecutionHandler`接口的方式。

## 六 提交任务的几种方式

往线程池中提交任务，主要有两种方法，`execute()`和`submit()`。

`execute()`用于提交不需要返回结果的任务，我们看一个例子。



```java
public static void main(String[] args) {
    ExecutorService executor = Executors.newFixedThreadPool(2);
    executor.execute(() -> System.out.println("hello"));
}
```

`submit()`用于提交一个需要返回果的任务。该方法返回一个`Future`对象，通过调用这个对象的`get()`方法，我们就能获得返回结果。`get()`方法会一直阻塞，直到返回结果返回。另外，我们也可以使用它的重载方法`get(long timeout, TimeUnit unit)`，这个方法也会阻塞，但是在超时时间内仍然没有返回结果时，将抛出异常`TimeoutException`。



```java
public static void main(String[] args) throws Exception {
    ExecutorService executor = Executors.newFixedThreadPool(2);
    Future<Long> future = executor.submit(() -> {
        System.out.println("task is executed");
        return System.currentTimeMillis();
    });
    System.out.println("task execute time is: " + future.get());
}
```

## 七关闭线程池

在线程池使用完成之后，我们需要对线程池中的资源进行释放操作，这就涉及到关闭功能。我们可以调用线程池对象的`shutdown()`和`shutdownNow()`方法来关闭线程池。

这两个方法都是关闭操作，又有什么不同呢？

1.  `shutdown()`会将线程池状态置为`SHUTDOWN`，不再接受新的任务，同时会等待线程池中已有的任务执行完成再结束。
2.  `shutdownNow()`会将线程池状态置为`SHUTDOWN`，对所有线程执行`interrupt()`操作，清空队列，并将队列中的任务返回回来。

另外，关闭线程池涉及到两个返回boolean的方法，`isShutdown()`和`isTerminated`，分别表示是否关闭和是否终止。

## 八如何正确配置线程池的参数

前面我们讲到了手动创建线程池涉及到的几个参数，那么我们要如何设置这些参数才算是正确的应用呢？实际上，需要根据任务的特性来分析。

1. 任务的性质：CPU密集型、IO密集型和混杂型
2. 任务的优先级：高中低
3. 任务执行的时间：长中短
4. 任务的依赖性：是否依赖数据库或者其他系统资源

不同的性质的任务，我们采取的配置将有所不同。在《Java并发编程实践》中有相应的计算公式。

通常来说，如果任务属于CPU密集型，那么我们可以将线程池数量设置成CPU的个数，以减少线程切换带来的开销。如果任务属于IO密集型，我们可以将线程池数量设置得更多一些，比如CPU个数*2。

> PS：我们可以通过`Runtime.getRuntime().availableProcessors()`来获取CPU的个数。

## 九线程池监控

如果系统中大量用到了线程池，那么我们有必要对线程池进行监控。利用监控，我们能在问题出现前提前感知到，也可以根据监控信息来定位可能出现的问题。

那么我们可以监控哪些信息？又有哪些方法可用于我们的扩展支持呢？

首先，`ThreadPoolExecutor`自带了一些方法。

1.  `long getTaskCount()`，获取已经执行或正在执行的任务数
2.  `long getCompletedTaskCount()`，获取已经执行的任务数
3.  `int getLargestPoolSize()`，获取线程池曾经创建过的最大线程数，根据这个参数，我们可以知道线程池是否满过
4.  `int getPoolSize()`，获取线程池线程数
5.  `int getActiveCount()`，获取活跃线程数（正在执行任务的线程数）

其次，`ThreadPoolExecutor`留给我们自行处理的方法有3个，它在`ThreadPoolExecutor`中为空实现（也就是什么都不做）。

1.  `protected void beforeExecute(Thread t, Runnable r)` // 任务执行前被调用
2.  `protected void afterExecute(Runnable r, Throwable t)` // 任务执行后被调用
3.  `protected void terminated()` // 线程池结束后被调用