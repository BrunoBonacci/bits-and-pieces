---
layout: post
title:  "Clojure Pills: Integers number"
date:   2013-03-16 22:00:00
categories: [development]
tags: [Clojure]
---


Clojure supports integers (like any other high level language) and when possible they are mapped to `java.lang.Long` objects. Numbers in Clojure are evaluated to themselves.

``` clojure
1
;= 1
-350
;= -350

(type 1)
;= java.lang.Long
```

type is a function that return the Java class of an object/value.

More interestingly Clojure supports arbitrary large integers:

``` clojure
983475029384572039842462736458726354265428376576528347562834567485
;= 983475029384572039842462736458726354265428376576528347562834567485N

(type 983475029384572039842462736458726354265428376576528347562834567485)
;= clojure.lang.BigInt
```

However, when it comes to maths, be careful about the size of your numbers or you will still run into trouble:

``` clojure
(+ 100 50 50)
;= 200

(+ 1 java.lang.Long/MAX_VALUE)
; ArithmeticException integer overflow  clojure.lang.Numbers.throwIntOverflow (Numbers.java:1388)

; java.lang.Long/MAX_VALUE + 1 = 9223372036854775808
(+ 1 9223372036854775808)
;= 9223372036854775809N

(type (+ 1 9223372036854775808))
;= clojure.lang.BigInt
```

In other words Clojure tries to map integers to Java’s native type Long when possible with the benefit of efficient maths operations. In that case Java limits apply.
When it is not possible to map a number into a java.lang.Long, then a BigInt is used. When found mixed types in operations like +, the largest type is used for the result. If you want to use a BigInt also for your “small” numbers then append an “N” to your integers.

``` clojure
(type 1)
;= java.lang.Long

(type 1N)
;= clojure.lang.BigInt

(type (+ 1 1N))
;= clojure.lang.BigInt

(+ 1N java.lang.Long/MAX_VALUE)
;= 9223372036854775808N
```

Finally, integers can be written as decimal, hexadecimal, octal, radix-32, and binary literals. For example the number 127 can be written as follow:

``` clojure
[127 0x7F 0177 32r3V 2r01111111]
;= [127 127 127 127 127]
```

The radix notation supports up to base 36 and the notation is:

``` clojure
; {base}r{number}
```

Check this post about [Arithmetics and type autopromotion]({% post_url 2013-06-21-clojure-pills-arithmetics-and-type-autopromotion %})
