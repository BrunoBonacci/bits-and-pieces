---
layout: post
title:  "Clojure Pills: Arithmetics and type autopromotion"
date:   2013-06-21
categories: [development]
tags: [Clojure]
---

In a previous post about [Integer numbers]({% post_url
2013-03-16-clojure-pills-integers-number %}) we have seen that Clojure
for efficiency reasons tries to map the numbers to their Java basic
types and that with the literals modifiers "N" for integers and "M"
for decimals you can use BigIntegers and BigDecimals in place of the
Long and Double.

Clojure in addition to the basic arithmetic operators (+, -, *) who
leverage the speed of the Java platform basic types, it offers a
series of operators that instead of throwing and exception when the
type limit are crossed, it automatically promote the type to the
higher capable counterpart. Those operators are +', -' and *' (like
normal operators followed by a single quote. Lets see them in action.

For example:

``` clojure
;; this is bigger than java.lang.Long can represent
(+ 1 java.lang.Long/MAX_VALUE)
; ArithmeticException integer overflow  clojure.lang.Numbers.throwIntOverflow (Numbers.java:1388)

;; but with the auto-promotion operators you can write this as:
(+' 1 java.lang.Long/MAX_VALUE)
;=> 9223372036854775808N

(-' java.lang.Long/MAX_VALUE -1)
;=> 9223372036854775808N

(*' 2 java.lang.Long/MAX_VALUE)
;=> 18446744073709551614N

;; it preserves the basic type when possible
(type (+ 1 1))
;=> java.lang.Long
(type (+' 1 1))
;=> java.lang.Long
```

So if you expect that your operations might go beyond the Java's Long limits, use the auto-promotion operator and avoid the arithmetics overflow.

Let's calculate the factorial:

``` clojure
;;                  v--- auto promotion
(defn ! [x] (reduce *' (range 1 (inc x))))

(! 5)
;=> 120

(! 5000)
;=> 422857792660554352220106420023358440539078667 .... N
;=> (VERY BIG NUMBER)
```
