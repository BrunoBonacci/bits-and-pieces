---
layout: post
title:  "Clojure Pills: Strings and Characters"
date:   2013-03-23 21:00:00
categories: [development]
tags: [Clojure]
---

Strings and characters in Clojure they have no surprises. They map respectively to `java.lang.String` and `java.lang.Character`. Both, strings and characters they evaluate to themselves.

``` clojure
"This is a string"
;= "This is a string"

(type "This is a string")
;= java.lang.String

"Strings in Clojure
 can be multi lines
 as well!!"
;= "Strings in Clojure \n can be multi lines \n as well!!"

\a       ; this is the character 'a'
\A       ; this is the character 'A'
\\       ; this is the character '\'
\u0041   ; this is unicode for  'A'
\tab     ; this is the tab character
\newline ; this is the newline character
\space   ; this is the space character

\a
;= \a
(type \a)
;= java.lang.Character
```

Since they map to their Java’s native type you can use all java.lang.String methods

``` clojure
(.toUpperCase "This is a string")
;= "THIS IS A STRING"

(seq (.split "This is a string" " "))
;= ("This" "is" "a" "string")

;; a string is a sequence of characters
(seq "This is a string")
;= (\T \h \i \s \space \i \s \space \a \space \s \t \r \i \n \g)
```

There are a number of Clojure functions available to manipulate Strings:

``` clojure
;; to create a string
(str 123)
;= "123"

(str 1 "and" 3)
;= "1and3"

;; basically str calls .toString()
;; on the given arguments
(str (new java.util.Date))
;= "Sat Mar 23 02:27:32 GMT 2013"

;; check if the argument is a string
(string? "a string")
;= true

(string? 1)
;= false
```
