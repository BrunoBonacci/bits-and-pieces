---
layout: post
title: lumo vs planck vs clojure vs pixie.
subtitle: "Clojure(Script) engines comparison"
date:   2017-08-10 00:00:00
categories: [development]
tags: [Clojure]

author:
  name:  Bruno Bonacci
  image: bb.png
---

I was looking to use Clojure for scripting. A few years ago there was
not much options. Recently the scenario changed rapidly. The options
currently available are:

  * Use Clojure in the JVM with [lein-binplus](https://github.com/BrunoBonacci/lein-binplus)
  * Use ClojureScript with [lumo](https://github.com/anmonteiro/lumo)
  * Use ClojureScript with [planck](https://github.com/mfikes/planck)
  * Use [pixie-lang](https://github.com/pixie-lang/pixie)


Each of the options have advantages and disadvantages. Clojure with
the JVM has brings the full power of the JVM, the portability to many
different target platforms, an endless ecosystem of libraries,
multi-threading, etc. However the JVM+Clojure has a startup cost
which is more accentuated on short execution scripts.

ClojureScript engines have emerged more recently thanks to the fact
that the ClojureScript compiler is now bootstrapped in JavaScript
(aka: you don't need Java to compile ClojureScript).

Two tools, in this space, have become quite popular
recently: [planck](https://github.com/mfikes/planck)
and [lumo](https://github.com/anmonteiro/lumo). The first one
uses
[JavaScriptCore](https://developer.apple.com/documentation/javascriptcore) ported
to `C` for portability. The second one
uses [V8 engine](https://github.com/v8/v8).  Both offer ways to
connect to the host system and to leverage available libraries in the
ClojureScript ecosystem.

Finally [pixie-lang](https://github.com/pixie-lang/pixie) is a
Clojure-like language which implements its own virtual machine on top
of the [RPython](https://rpython.readthedocs.io/en/latest/) framework.
Isn't fully compatible with Clojure, however is similar enough to feel
familiar. Additionally it offers a easy FFI access which allows
easy access to native C libraries. It implement its own tracing JIT
compiler.

I ran a few tests with all of them and one test in particular surprised me.
I ran the following script in all of them and capture the execution time:

``` clojure
(defn Σ [n]
  (reduce + (range (inc n))))

(println (Σ 1000000000))
```

Here are the results:

### Lumo

``` bash
$ lumo --help
Lumo 1.6.0
(...)

$ time lumo -e "(defn Σ [n] (reduce + (range (inc n)))) (println (Σ 1000000000))"
#'cljs.user/Σ
500000000067109000

real     0m46.851s
user     0m46.750s
sys      0m0.123s
```

### Planck

``` bash
$ planck -V
2.6.0

$ time planck -e "(defn Σ [n] (reduce + (range (inc n)))) (println (Σ 1000000000))"
500000000067109000

real    0m17.756s
user    0m17.972s
sys     0m1.504s
```

### JVM Clojure

``` bash
$ java -version
java version "1.8.0_45"
Java(TM) SE Runtime Environment (build 1.8.0_45-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.45-b02, mixed mode)

$ time java -jar clojure-1.8.0.jar -e "(defn Σ [n] (reduce + (range (inc n)))) (println (Σ 1000000000))"
#'user/Σ
500000000500000000

real    0m7.554s
user    0m7.891s
sys     0m0.437s
```

### Pixie-lang

``` bash
$ ./pixie-vm -v
Pixie 0.1 (36ce07e)

$ time ./pixie-vm -e "(defn Σ [n] (reduce + (range (inc n)))) (println (Σ 1000000000))"
500000000500000000

real    0m0.672s
user    0m0.659s
sys     0m0.008s
```

## Results

Summary table:

``` text
| Tool           | Elapsed time |
|----------------|-------------:|
| lumo           |      46.851s |
| planck         |      17.756s |
| JVM            |       7.554s |
| JVM (pre-warm) |       6.320s |
| pixie          |       0.672s |
```


Now leaving aside the fact that for some reason both `planck` and
`lumo` got the wrong result [[^1]], the difference in timing
is impressive.  The most impressive result is the `pixie-vm` JIT
performance which in this special case of tight loop it goes even
faster than the JVM.  Even removing the JVM cold start and Clojure
compilation JVM still performs around `6.3s`.

I don't know whether the work on `pixie` it is going to proceed,
however the benchmark result is the testament of the great work
that _Timothy Baldridge et al._ have put into this project.

---

##### Footnotes:

   [^1]: `planck` and `lumo` and ClojureScript in general are hosted
    on top of JavaScript. [JavaScript
    specifications](https://www.ecma-international.org/ecma-262/6.0/#sec-terms-and-definitions-number-value)
    defines only one type of primitive numeric value which is a
    double-precision 64-bit **floating point** binary **format IEEE
    754-2008** value. This floating point format defines 53-bits for
    the mantissa which stores the actual number, some of which could
    be decimal part. If you are representing a integer value then you
    can use all 53-bits for the integer part. Therefore the largest
    integer you can represent in this case is `2^53 -1` which is
    **9007199254740991**. The reason why `planck` and `lumo` show a
    different result is that the result of the operation is way larger
    than the max integer in JavaScript so the sum operator computes
    the result and it rounds it up to the nearest representable value
    in *IEEE 754-2008 format* (see: [Applying the Additive Operators
    to
    Numbers](https://www.ecma-international.org/ecma-262/6.0/#sec-applying-the-additive-operators-to-numbers)). Clojure
    over Java or .Net and `pixie` use a 64-bit integer format which it
    can fully represent the result of the operation.
