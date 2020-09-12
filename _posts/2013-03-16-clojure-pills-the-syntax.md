---
layout: post
title:  "Clojure Pills: The syntax"
date:   2013-03-16 19:00:00
categories: [development]
tags: [Clojure]
---

LISP derived languages have a bad reputation for the excessive use of brackets. At first sight it’s bit hard to understand Clojure source code. If you try to google “LISP brackets” you will find a list of rants and discussions about this topic.

However after few weeks your eye starts to get accustomed to the new syntax and things become incredibly clear. Clojure syntax is extremely simple compared to Java, Ruby or Groovy. Here some of its basic elements.

``` clojure
; this is a comment

;; anything you put after a semicolon
;; till EOL is considered a comment
```

In Clojure source code you will often see comments starting with one semicolon or two semicolons.
For Clojure reader there is no difference between the two, often it’s left as a personal choice of style.
For example is common to see whole line comments starting with two semicolons (;;) while in-line comments with one.

You can find a bit more info about this topic in this post: [What is the difference between ; and ;; in Clojure code comments?](http://stackoverflow.com/questions/5084191/what-is-the-difference-between-and-in-clojure-code-comments)

Additionally there are tools like [Marginalia](https://github.com/gdeer81/marginalia) that parses the source code and uses comments and others elements to produce a very nice code documentation.

``` clojure
; this is a list
'(1 2 3)

;; this is a function call
(println "hello" "world" "!!")
;; this means
;; (func-to-call arg1    arg2    arg3)
;; (println      "hello" "world" "!!")
```

The function call share the same representation of the list data structure. In fact the first element of the list is the function name and all remaining
elements are parameters (arguments) of that function.

The reason why I prefix with a single quote `'(1 2 3)` is because otherwise Clojure would have attempted to call a function named 1 passing parameters 2, 3.

There are others elements of Clojure syntax such as symbols, keywords, vectors, maps, sets and of course functions and all of them can be passed as argument to other functions. You can see a more comprehensive list of Clojure elements here: [Clojure reader](http://clojure.org/reader).

The choice of using the list to represent the data and the function calls (code) has a profound implication in the language. This property is called homoiconicity and the obvious advantage is that you can treat the code as data and manipulate the code in the same way and using the same functions that you use to manipulate program’s data lists. This will come very handy when we will explore the macros.
