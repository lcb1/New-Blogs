# Java集合学习

![1155586-20191121113013129-777098617](assets/1155586-20191121113013129-777098617.jpg)

## 线性集合

| 类         | 底层数据结构 | 线程安全   | 优点       | 缺点       |
| ---------- | ------------ | ---------- | ---------- | ---------- |
| ArrayList  | 数组         | 非线程安全 | 查找快     | 插入删除慢 |
| LinkedList | 链表         | 非线程安全 | 插入删除快 | 查找慢     |
| Vector     | 数组         | 线程安全   | 查找快     | 插入删除慢 |

## 栈

> 栈可用数组,链表,双向队列模拟
>
> Stack   继承自Vector 底层使用数组线程安全效率低下 可使用ConcurrentLinkedDeque代替

