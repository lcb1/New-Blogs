# Java阻塞队列

## BlockingQueue的操作

| 操作 | 抛出异常  | 返回指定的值 | 无限阻塞 | 超时阻塞           |
| :--- | :-------- | :----------- | :------- | :----------------- |
| 插入 | add(e)    | offer(e)     | put(e)   | offer(e,time,unit) |
| 移除 | remove()  | poll()       | take()   | poll(time,unit)    |
| 检查 | element() | peek()       | 不提供   | 不提供             |

> 阻塞队列BlockingQueue不支持null值插入，实现类在调用add，put或者offer一个null值的时候会抛出异常，因为null值在队列里面作为一个哨兵值用来展示poll操作失败的返回值，如果允许null值插入，则这个值的语义就会模糊。
>
> BlockingQueue队列的实现有无界限队列和有界限队列，任何时候如果put操作的值如果大于了界限值，那么put操作将会阻塞，其实严格意义的说阻塞队列也是有界限的内部默认最大值是 Integer.MAX_VALUE.

## 主要的实现类

> ```java
> ArrayBlockingQueue, 一个基于数组实现有界阻塞队列
> LinkedBlockingQueue, 一个基于链表实现的无界阻塞队列
> PriorityBlockingQueue, 一个基于数组实现的支持优先级排序的无界阻塞队列
> DelayQueue, 一个基于数组使用优先级队列实现的无界阻塞队列
> LinkedBlockingDeque, 一个基于链表实现的双向阻塞队列
> SynchronousQueue，一个基于不实际存储元素的阻塞队列
> LinkedTransferQueue, 一个基于链表实现的无界阻塞队列
> ```

## 原理实现

> (一）ArrayBlockingQueue介绍和实现原理分析
>
> ArrayBlockingQueue是基于数组实现的有界的先进先出的阻塞队列，所以我们可以说队列的头部是队列中呆的时间最长的或者叫最早的，而队列的尾部则是刚刚呆的时间最短的，因为尾部的元素都是最新插入的。新来的元素都会被追加到队列的尾部，而出队操作是从队列的头部开始的。数组实现的阻塞队列可以充当典型的有界的buffer队列，因为其长度固定，一旦创建就不能变化，在队列满了或者空了对应的生产者和消费者都会进入阻塞状态，此外数组队列还提供了可选的公平性策略，默认情况下是非公平，也就是说默认的访问是随机访问的，拥有更高的吞吐量，当设置成公平模式时，可以保证先进先出避免饥饿，但吞吐量会下降。

> 实现原理分析： ArrayBlockingQueue实现并不复杂，内部采用了一个Object数组来保存元素，使用了ReentrantLock来保证同步，并通过重入锁的两个condition条件队列来分别控制生产者和消费者的阻塞和唤醒的调度通信，元素的插入和删除均是对数组的元素赋值，取走了就赋值null，其他就是数据本身，不像链表是按需所取。
>
> （二）LinkedBlockingQueue介绍和实现原理分析
>
> LinkedBlockingQueue也是基于先进先出的阻塞队列，其容量可以有界的也可以是无界的（Integer.MAX_VALUE.），我们可以通过构造函数设置LinkedBlockingQueue相比ArrayBlockingQueue在大多数时候具有更高的吞吐量，但是由于链表的动态性所以其性能常常不稳定或者说难以预料。
>
> 实现原理分析：
>
> LinkedBlockingQueue底层相比ArrayBlockingQueue要复杂，LinkedBlockingQueue采用了双锁队列，针对put和offer方法单独的使用一个锁，针对take和poll则采用了take锁，此外由于是两个锁，所以计数器count采用Atomic变量来更新，这样避免了同时操作2个锁来更新数据，这里面有个可见性的问题，因为2个锁是独立的也就是put和take分别使用的不同的同步块，那么put的数据在take里面如何使可见的？
>
> 在Java官网文档介绍，仅仅基于同一个监视器的锁，一个线程释放后另一个线程获得锁后才能得到可见性，但在这里却是利用volatile的增强语义来保证的可见性，put操作会更新使用volatile修饰的count变量，之后如果有读线程进入，如果先访问volatile修饰的count变量，那么volatile写对于读具有hanppend-before关系，也就是说只要访问了volatile变量，那么之前在不同锁的线程修改的数据会强制刷新到主cache里面，这样读线程就能够读取了，但这仅仅保证了可见性，对于原子性，是如何保证的呢？ 这里恰恰是利用了队列的特点，队列的特点是头节点出队，末尾节点进队，也就是说任何时候不存在两个线程同时修改同一个节点从而巧妙的避免了该问题。
>
> （三）PriorityBlockingQueue的介绍和实现原理分析
>
> PriorityBlockingQueue这个队列比较特殊，可以根据自定义的优先级来构建一个有序的二叉堆数据结构，这种结构在插入数据的时候就能够根据自定义的排序规则（对象实现Compareable和Comparator）来生成一个有序的堆，通过这样来定义一个按优先级顺序的队列集合，不再是默认的先进先出规则，需要注意的是优先级队列的put方法并不阻塞，默认的数组的长度是11，在插入满的时候会扩容。take方法在队列为空的时候会进入阻塞状态。
>
> 实现原理分析：
>
> PriorityBlockingQueue使用一个ReentrantLock锁和一个控制消费者空的时候的condition条件队列，大多数操作都通过重入锁来保证互斥操作，唯一有一点特殊的地方在于，数组扩容的时候采用了自旋锁来控制，为了避免在扩容期间导致其他的并发操作不能进行。注意扩容是新生成一个容量更大的数组，等生成完毕之后，还是需要以独占锁的方法，先替换引用，然后在拷贝老数组的数据到扩容后的数组中。
>
> （四）DelayQueue的介绍和实现原理分析
>
> DelayQueue也是一个基于数组实现的阻塞队列，这个队列的功能可以说是PriorityBlockingQueue队列的加强版，首先其内部用的是PriorityQueue队列来存储相关的数据，这个优先级队列底层使用的也是二叉堆构建的数组数据结构，其中在DelayQueue的泛型中限制了其类必须是继承了Delayed这个类本身或者子类，在插入的时候一个有序的二叉堆便已经生成，与PriorityBlockingQueue不同的时，除了根据自定义的方法排序外，DelayQueue还支持延迟消费，也就说生产者创建的消息，在消费者消费的时候，并不说立刻就拿走了，还要判断延迟的时间是否到期，如果到期了才能消费，否则继续等待直到延迟的时间过时才能消费。
>
> 实现原理分析：
>
> 这个类的大部分与PriorityBlockingQueue类似，不同点在于消费者消费数据的时候，会先通过peek方法取头部的元素出来，然后判断是否超时。如果没有超时，就调用Condition.awaitNanos(ns)方法阻塞到该数据超时时间，在此期间的其他消费者现场都必须阻塞等待，因为头部的元素的还没超时，头部后面的元素更不会超时，因为该队列是排序过的。此外，该队列作为无界队列，插入方法也永远不会进入阻塞， 这个类也是使用的 ReentrantLock和条件量实现的同步策略。
>
> （五）LinkedBlockingDeque的介绍和实现原理分析
>
> LinkedBlockingDeque这个阻塞队列与LinkedBlockingQueue基本类似，两点区别如下：
>
> （1）该阻塞队列是一个双向的链表结构，既然是双向，那么就意味着链表的两端都可以作为head，所以该类的api提供了特定add，put,take,peek,pool,remove,offer相关的xxxLast和xxxFirst方法，基于这些方法就能够从队列的两端进行操作。
>
> （2）由于双向链表操作的复杂性，所以这个类的底层同步策略，并没有像LinkedBlockingQueue作双锁队列，仅仅用了一个ReentrantLock和两个条件队列来管理所有的访问操作，这么的目的应该是简化实现，毕竟这个类的使用频次并不是很高。
>
> （六）SynchronousQueue的介绍和实现原理分析
>
> 这个队列在之前的文章中分析中，SynchronousQueue不存储实际的元素，仅仅是维护了两个线程队列，是一个生产者，一个消费者，采用类似CSP的模型，类似约会机制只要凑够一个生产者对一个消费者就立即执行，否则条件不满足就进入阻塞，消费者不关注消息是那个生产者的。生产者也不关注那个消费者取走了消息，这种模式在1对1的线程交换场景中效率比较高。
>
> （七）LinkedTransferQueue的介绍和实现原理分析
>
> LinkedTransferQueue也是一个比较特殊的阻塞队列，其结合了SynchronousQueue和LinkedBlockingQueue优点，所以综合来说效率更高：
>
> SynchronousQueue的优点在于1对于1的传递模型效率极高，但如果有大量数据时候，生产者和消费者的速率不均衡那么性能就会大大下降，因为忙不过来的时候线程会阻塞。
>
> LinkedBlockingQueue内部实现是通过加锁实现的，虽然已经在实现上有过优化，但整体来说表现一般。
>
> LinkedTransferQueue同时兼具他们的优点，额外提供了如下几种方法：
>
> ```javascript
> transfer(E e)：若当前存在一个正在等待获取的消费者线程，即立刻移交之；否则，会插入当前元素e到队列尾部，并且等待进入阻塞状态，到有消费者线程取走该元素。
> tryTransfer(E e)：若当前存在一个正在等待获取的消费者线程（使用take()或者poll()函数），使用该方法会即刻转移/传输对象元素e；若不存在，则返回false，并且不进入队列。这是一个不阻塞的操作。
> tryTransfer(E e, long timeout, TimeUnit unit)：若当前存在一个正在等待获取的消费者线程，会立即传输给它;否则将插入元素e到队列尾部，并且等待被消费者线程获取消费掉；若在指定的时间内元素e无法被消费者线程获取，则返回false，同时该元素被移除。
> hasWaitingConsumer()：判断是否存在消费者线程。
> getWaitingConsumerCount()：获取所有等待获取元素的消费线程数量。
> ```
>
> LinkedTransferQueue在插入元素的时候可以优化成，如果当前已经有消费者在等待获取数据，那么生产者线程的数据则直接通过transfer方法传递给该线程，避免了入队的开销，当然如果还可以采用异步的方法插入，tryTransfer方法会判断当前是否有消费者在等待获取数据，如果没有则数据入队，返回false，如果有则直接交换。最后还提供了可以指定一段超时的版本在一定时间内如果有消费者进入，那么就直接交换。前面说的，反之亦然，就是说如果在消费者视角也是一样的。

参考自https://cloud.tencent.com/developer/article/1350854

