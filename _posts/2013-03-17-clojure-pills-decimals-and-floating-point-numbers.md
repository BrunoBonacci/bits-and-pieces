---
layout: post
title:  "Clojure Pills: Decimals and floating point numbers"
date:   2013-03-17 20:00:00
categories: [development]
tags: [Clojure]
---

Similarly to my previous post about [Integer numbers]({% post_url 2013-03-16-clojure-pills-integers-number %}), Clojure has a support for floating point numbers, by default mapped as java.lang.Double and arbitrary precise decimals mapped as java.math.BigDecimal.

``` clojure
;; floating point mapped as java.lang.Double
1.0
-3.5
1234e-3
(type 1.0)
;= java.lang.Double

;; BigDecimals
1.0M
-3.5M
29085673904875.0398475293847523984752837465283476583475M
(type 1.0M)
;= java.math.BigDecimal
```

One difference between integers and floating point decimals in Clojure is in the way it handles basic computation. We seen in the previous post that when try to mix “small” integers and “big” integers in a calculation, Clojure always uses the largest type as return type. This seems not to be happening for the floating point and big decimals

``` clojure
(type (+ 1 1N))
;= clojure.lang.BigInt

(type (+ 1.0 1.0M))
;= java.lang.Double
```

It is really important to keep in mind this subtle difference because you need only one Double mixed in your “precise” calculus to truncate the precision down to a java.lang.Double with potentially disastrous effects.

``` clojure
(+ 0.3M  0.3M  0.3M  0.1M )
;= 1.0M
(type (+ 0.3M  0.3M  0.3M  0.1M ))
;= java.math.BigDecimal

;;              /---- Missing 'M'
(+ 0.3M  0.3M  0.3  0.1M )
;= 0.9999999999999999
(type (+ 0.3M  0.3M  0.3  0.1M ))
;= java.lang.Double
```

Next we’ll see [Clojure rationals]({% post_url 2013-03-17-clojure-pills-rational-numbers %}) in action.
