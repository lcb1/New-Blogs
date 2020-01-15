# Manacher 算法

*2019/12/28*

## manacher 简介

> 1975年，一个叫Manacher的人发明了一个算法，Manacher算法（中文名：马拉车算法），该算法可以把时间复杂度提升到*O*(*n*)。

## 一: 背景

> 给定一个字符串，求出其最长回文子串。例如：
>
> 1. s="abcd"，最长回文长度为 1；
> 2. s="ababa"，最长回文长度为 5；
> 3. s="abccb"，最长回文长度为 4，即bccb。
>
> 以上问题的传统思路大概是，遍历每一个字符，以该字符为中心向两边查找。其时间复杂度为O(n^2)，效率很差。

## 二:算法分析过程

> 由于回文分为偶回文（比如 bccb）和奇回文（比如 bcacb），而在处理奇偶问题上会比较繁琐，所以这里我们使用一个技巧，具体做法是：在字符串首尾，及各字符间各插入一个字符（前提这个字符未出现在串里）。
>
> 举个例子：`s="abbahopxpo"`，转换为`s_new="$#a#b#b#a#h#o#p#x#p#o#"`（这里的字符 $ 只是为了防止越界，下面代码会有说明），如此，s 里起初有一个偶回文`abba`和一个奇回文`opxpo`，被转换为`#a#b#b#a#`和`#o#p#x#p#o#`，长度都转换成了**奇数**。
>
> 定义一个辅助数组`int p[]`，其中`p[i]`表示以 i 为中心的最长回文的半径，例如：
>
> |    i     |  0   |  1   |  2   |  3   |  4   |  5   |  6   |  7   |  8   |  9   |  10  |  11  |  12  |  13  |  14  |  15  |  16  |  17  |  18  |  19  |
> | :------: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
> | s_new[i] |  ^   |  #   |  a   |  #   |  b   |  #   |  b   |  #   |  a   |  #   |  h   |  #   |  o   |  #   |  p   |  #   |  x   |  #   |  p   |  #   |
> |   p[i]   |      |  1   |  2   |  1   |  2   |  5   |  2   |  1   |  2   |  1   |  2   |  1   |  2   |  1   |  2   |  1   |  4   |  1   |  2   |  1   |
>
> 可以看出，`p[i] - 1`正好是原字符串中最长回文串的长度。
>
> 接下来的重点就是求解 p 数组，如下图：
>
> ![](https://segmentfault.com/img/remote/1460000014416801?w=590&h=190)
>
> 设置两个变量，mx 和 id 。mx 代表以 id 为中心的最长回文的右边界，也就是`max = id + p[id]`。
>
> 假设我们现在求`p[i]`，也就是以 i 为中心的最长回文半径，如果`i < max`，如上图，那么：
>
> ```Java
> if(i<max){
>                 p[i]=Math.min(p[2*id-i],max-i);
>             }
> ```
>
> `2 * id - i`为 i 关于 id 的对称点，即上图的 j 点，而**p[j]表示以 j 为中心的最长回文半径**，因此我们可以利用`p[j]`来加快查找。

## 三:代码

```java
/**
     * 转换函数,字符'^'为区分字符头部
     * 字符'$'为区分尾部,避免了越界检查
     * 由于回文分为偶回文（比如 bccb）和奇回文（比如 bcacb），而在处理奇偶问题上会比较繁琐，
     * 所以这里我们使用一个技巧，具体做法是：在字符串首尾，及各字符间各插入一个字符（前提这个字符未出现在串里）。
     * @param str
     * @return
     */
    public String convert(String str){
        StringBuilder builder=new StringBuilder("^#");
        for (int i=0;i<str.length();i++){
            builder.append(str.charAt(i)).append("#");
        }
        builder.append("$");
        return builder.toString();
    }
/***
     * author by : lcb
     * date : 2019/12/28 12:06
     * message: 
     */
    @Test
    public void testManacher(){
        String str=convert("aaa");
        int[] p=new int[str.length()];
        int max=0;
        int id=0;
        int res=0;
        for(int i=1;i<str.length()-1;i++){
            if(i<max){
                p[i]=Math.min(p[2*id-i],max-i);
            }else {
                p[i]=1;
            }
            while(str.charAt(i-p[i])==str.charAt(i+p[i])){
                p[i]++;
            }
            if(max<i+p[i]){
                id=i;
                max=i+p[i];
            }
            res=Math.max(res,p[i]-1);
        }
        System.out.println(res);
    }
```

*解决思路类似于动态规划,充分利用已知信息*

参考自https://segmentfault.com/a/1190000008484167?utm_source=tag-newest