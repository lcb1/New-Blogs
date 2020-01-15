# Redis Study

* 简介

  > REmote DIctionary Server(Redis) 是一个由Salvatore Sanfilippo写的key-value存储系统。
  >
  > Redis是一个开源的使用ANSI C语言编写、遵守BSD协议、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。
  >
  > 它通常被称为数据结构服务器，因为值（value）可以是 字符串(String), 哈希(Hash), 列表(list), 集合(sets) 和 有序集合(sorted sets)等类型

* Redis内置的数据结构

  >*  String   	字符串
  >* Hash          散列表
  >* List             列表
  >* Set               集合
  >* Sorted Set   有序集合

* 相关资源

  > Redis 官网：<https://redis.io/>
  >
  > Redis 在线测试：<http://try.redis.io/>

* 安装

  > * windows 安装
  >
  >   > **下载地址：**<https://github.com/MSOpenTech/redis/releases>。
  >
  > * Linux 安装
  >
  >   > **下载地址：**<http://redis.io/download>，下载最新稳定版本。
  >   >
  >   > ```shell
  >   > $ wget http://download.redis.io/releases/redis-2.8.17.tar.gz
  >   > $ tar xzf redis-2.8.17.tar.gz
  >   > $ cd redis-2.8.17
  >   > $ make
  >   > $ cd src
  >   > ```

* Redis 启动

> ```shell
> $ ./redis-server ../redis.conf
> ```

