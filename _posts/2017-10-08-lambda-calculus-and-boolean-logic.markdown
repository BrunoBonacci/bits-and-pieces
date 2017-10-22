---
layout:     post
title:      Lambda Calculus - Boolean logic.
subtitle:   "How to implement boolean logic."
date:       2017-10-08 00:00:00
categories: [development, theory]
tags:       [Lambda Calculus, Clojure]

author:
  name:  Bruno Bonacci
  image: bb.png
---

In this post I will introduce some of the basic concepts of the
_Lambda Calculus_ and use them to define basic terms and operators of
the boolean logic.

Recently, I was challenged to write a Clojure's macro called `IF`
which behaves like the `clojure.core/if` but doesn't use anything that
expands to it. This means that you can exclude pretty much all the
usual suspects in the core: `cond`, `condp`, `and`, `or`, `case`,
`cond->`, etc.

After feeling a bit lost for about a minute or so, I understood that
to solve this challenge I had to go back the primitive element of
computation. For example on `x86` the `if` it is implemented as a
combination of a comparison operation `cmp` and a jump operation `jz`
(jump if zero) [^1].

My best guess to solve the challenge was to artificially _jump to a
location_. However in Clojure there is no _jump_ instruction so the
only way to simulate something similar is to encode the jump location
into a map.  Therefore my solution was something like:

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

You can use this macro pretty much like the `clojure.core/if`.

``` clojure
   (IF (= 0 1) "OK" "KO")
   ;;=> "KO"

   (IF true "OK" "KO")
   ;;=> "OK"

   (IF false "OK" "KO")
   ;;=> "KO"
```

Although this works, I wasn't too happy with the solution. I thought
there must be _a more elegant solution_.  Since Clojure is a
functional language, I searched inspiration on the foundation of
functional programming languages and went back to *Alonzo Church* and
the *Lambda Calculus* ([^2]-[^3]). The Lambda Calculus defines the concept of
functions as computational boxes made only of very, very, very simple
elements.

The *Lambda Calculus* defines the following elements:
  - the `λ` sign to denote a function.
  - followed by a parameter name
  - then a dot `.`
  - and followed by an expression which is the body of the lambda.
  - a set of parenthesis can wrap the expression to make it unambiguous.
  - lambdas can optionally be *labelled*, in which case the label when
    found in another expression it expands to the lambda which it
    labels.

``` clojure
      (λx. M)
   ;;   |  \-> body
   ;;   \----> parameter
```

For example a `λ-abstraction` (or `λ-expression`) which increments a
number by one would be defined as:

``` clojure
      (λx. x + 1)
   ;;   |  ----
   ;;   |  \-> body
   ;;   \----> variable
```

Every time the `λ-expression` is applied to an argument the expression
is expanded by replacing the term with its body, and replacing the
variables with their values. For example:

``` clojure
   ((λx. x + 1) 3)
   (     3 + 1   )
   ;;=> 4
```

A `λ-expression` can also be *labelled*, once labelled the label can be
used in place of the expression and, if applied, it is replaced with
its definition.

``` clojure
   INC = (λx. x + 1)
   (INC 3)
   ((λx. x + 1) 3)
   (     3 + 1   )
   ;;=> 4
```


`λ-expressions` can also have multiple parameters.

``` clojure
   (λx. λy. x + y)

   ;; which can be simplified as:

   (λxy. x + y)
```

### Boolean logic.

Let's define `TRUE` as a `λ-expression` which takes two parameters and
returns the first.

``` clojure
   TRUE = (λxy. x)
```

Similarly, `FALSE` takes two parameters, but returns the second one:

``` clojure
   FALSE = (λxy. y)
```

Once we defined the basic boolean values then we can define logical
operators such as: `AND`, `OR` and `NOT`.

``` clojure
   AND = (λxy. (x (y TRUE FALSE) FALSE))
   OR  = (λxy. (x TRUE (y TRUE FALSE)))
   NOT = (λb.  (b FALSE TRUE)
```

Now let's try to test this logical operators:

``` clojure
   (AND TRUE FALSE)

   ;; expanding AND
   ((λxy. (x    (y     TRUE FALSE) FALSE)) TRUE FALSE)

   ;; replacing values into expansion
   (       TRUE (FALSE TRUE FALSE) FALSE)

   ;; expanding TRUE
   ((λxy. x) (FALSE TRUE FALSE) FALSE)

   ;; replacing values into expansion
   (FALSE TRUE FALSE)

   ;; expanding FALSE
   ((λxy. y) TRUE FALSE)

   ;; replacing values into expansion
   ;; which is also the final result.
   FALSE
```

Once we have these three basic operators we can implement the entire
boolean logic including something that behaves like `IF`.


``` clojure
   IF = (λbxy. ((b TRUE FALSE) x y)
```

Where `b` is the result of the boolean logic predicate expression, `x`
is the value to return when the `b` is true, `y` otherwise.

``` clojure
   (IF TRUE  "OK" "FAIL")
   ;;=> "OK"

   (IF FALSE "OK" "FAIL")
   ;;=> "FAIL"
```

Clojure is _unsurprisingly_ very similar to the _Lambda Calculus_ definition

For example:

``` clojure
   ;; Lambda Calculus' λ-expression
   (λxy. x + y)

   ;; Clojure's λ-expression
   (fn [x y] (+ x y))
```

and with the label:

``` clojure
   ;; Lambda Calculus' λ-expression
   SUM = (λxy. x + y)

   ;; Clojure
   (def SUM (fn [x y] (+ x y)))
```

So if we redefine everything using Clojure's lambdas we get something like:

``` clojure
   (def TRUE  (fn [x y] x))
   (def FALSE (fn [x y] y))

   (def NOT   (fn [b] (b FALSE TRUE)))

   (NOT TRUE) ;;=> FALSE

   (def AND (fn [x y]
              (x (y TRUE FALSE) FALSE)))

   (AND FALSE TRUE) ;;=> FALSE
   (AND TRUE TRUE)  ;;=> TRUE

   (def OR (fn [x y]
             (x TRUE (y TRUE FALSE))))

   (OR FALSE FALSE) ;;=> FALSE
   (OR FALSE TRUE)  ;;=> TRUE

   (def IF
     (fn [b x y]
       ((b TRUE FALSE) x y)))

   (IF (NOT FALSE)      "OK" "FAIL") ;;=> "OK"
   (IF (AND FALSE TRUE) "OK" "FAIL") ;;=> "FAIL"

```


At this point we pretty much have everything we need, with the only
difference that the evaluation of the _λ-expressions_ in _Lambda
Calculus_ is always delayed (_lazy evaluation_).  In Clojure,
function evaluation is done by first evaluating all the parameters,
and then evaluating the function itself. However, Clojure macros (and
special forms) take in input the forms (rather than the values)
allowing more fine grained control.

For example, our new `IF` function will evaluate both branches
of the expression before calling the function itself.

``` clojure
   ;; note: both branches are evaluated.
   (IF TRUE (println "OK") (println "FAIL"))
   OK
   FAIL
   ;;=> nil
```

To match the behaviour of `clojure.core/if` we need to evaluate only
the branch which is returned. So like I did in my first `IF`
implementation I have to turn it into a macro and wrap each branch
into a thunk.

``` clojure
   (defmacro IF [b x y]
       `(((~b TRUE FALSE) (fn [] ~x) (fn [] ~y))))

   ;; note: only the correct branch is evaluated.
   (IF TRUE (println "OK") (println "FAIL"))
   OK
   ;;=> nil
```

### Conclusions

It has been an interesting journey to the origins of computational
theory and functional programming theory. It is fascinating to see
that it is possible to build pretty much anything out of very very
simple elements. _Lambda Calculus_ has no concept of boolean logic or
branching operations, and yet we managed to build all common boolean
logic operators and the `if` special form.

The _Lambda Calculus_ has much more to offer. Reduction logic and
combinators deserve a post on their own.

As final note there is to say that `clojure.core/case` [^4] doesn't
expand to `if` but, actually, it uses a technique which is similar to
my first solution. A map is built for every case and a thunk is
associated with every key. A the time I wrote my solution I was
unaware of this.

### Final code.

Here all the final code.

``` clojure
   (def TRUE  (fn [x y] x))
   (def FALSE (fn [x y] y))

   (def NOT   (fn [b] (b FALSE TRUE)))

   (NOT TRUE) ;;=> FALSE

   (def AND (fn [x y]
              (x (y TRUE FALSE) FALSE)))

   (AND FALSE TRUE) ;;=> FALSE
   (AND TRUE TRUE)  ;;=> TRUE

   (def OR (fn [x y]
             (x TRUE (y TRUE FALSE))))

   (OR FALSE FALSE) ;;=> FALSE
   (OR FALSE TRUE)  ;;=> TRUE

   (defmacro IF [b x y]
       `(((~b TRUE FALSE) (fn [] ~x) (fn [] ~y))))

   (IF TRUE (println "OK") (println "FAIL"))
   OK
   ;;=> nil
```

### References
  [^1]: [X86 Assembly Control Flow](https://en.wikibooks.org/wiki/X86_Assembly/Control_Flow#Comparison_Instructions)
  [^2]: [An Introduction to the Lambda Calculus - Goldberg 2000](https://users.dcc.uchile.cl/~abassi/Cursos/41a/lambdacalc.pdf)
  [^3]: [Lambda Calculus - Computerphile](https://www.youtube.com/watch?v=eis11j_iGMs)
  [^4]: [clojure.core/case source code](https://github.com/clojure/clojure/blob/clojure-1.9.0-alpha14/src/clj/clojure/core.clj#L6579)
