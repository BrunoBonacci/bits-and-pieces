---
layout:     post
title:      Lambda Calculus - Boolean logic.
subtitle:   "How to implement boolean logic."
date:       2017-10-08 00:00:00
categories: [development, theory]
tags:       [Clojure]

author:
  name:  Bruno Bonacci
  image: bb.png
---


Recently, I was challenged to write a Clojure's macro called `IF`
which behaves like the `clojure.core/if` but doesn't use anything that
expands to it. This means that you can exclude pretty much all the
usual suspects in the core: `cond`, `condp`, `and`, `or`, `case`,
`cond->`, etc.

After feeling a bit lost for about a minute or so, I understood that
to solve this challenge I had to go back the primitive element of
computation. For example on `x86` the `if` it is implemented as a
combination of a comparison operation `cmp` and a jump operation `jz`
(jump if zero) (see: [resource](https://en.wikibooks.org/wiki/X86_Assembly/Control_Flow#Comparison_Instructions)).

So the best guess for to artificially _jump to a location_. However in
Clojure there are not jumps instruction so the only way to simulate
something similar is to encode the jump location into a map.
Therefore my solution was something like:

``` clojure
(defmacro IF [test t f]
    `(({true  (fn [] ~t)
        false (fn [] ~f)} (boolean ~test))))
```

In other words:

- evaluate the `test` expression and convert the result into a
  boolean value.

- create a map with `true` and `false` as key and a *thunk* function
  as a value which wraps the truthy and falsey expressions.

- use the map as function to lookup the result of the `test`.

- evaluate the resulting thunk by wrapping the expression with an
  additional pair of brackets `()`.



;;
