---
layout: post
title:  "Clojure Pills: keywords"
date:   2013-03-17 22:00:00
categories: [development]
tags: [Clojure]
---


The keywords concept is unknown to most of the programming languages.
The closest concept to a keyword in Java is an enumeration with the difference that enumerated values are in Java grouped in a surrounding type.

For example take the sizes, a Java enumeration will look like:

``` java
public enum Size { small, medium, large }
```

In Clojure they will be individual keywords that optionally can be grouped in a set or vector.

``` clojure
:small
:medium
:large

;; in a vector
[:small, :medium, :large]

;; as key in a map
{ :firstname "Bruno", :lastname "Bonacci" }
```

The keyword (like numbers and strings), in Clojure, always evaluate to themselves. The most common use is as key in maps.
Keywords are also functions that work with maps and sets. With maps they return the associated value in the map (if it exists), nil otherwise. In conjunction with sets they can be used to test if the keyword is present in the set.
This method is more efficient than using a string as key because the equality comparison is more efficient in the keywords.

``` clojure
;; creating a map
(def my-map { :firstname "Bruno", :lastname "Bonacci" })

;; retrieving the firstname
(:firstname my-map)
;= "Bruno"

;; if the keyword doesn't exists, nil is returned
(:age my-map)
;= nil

;; be careful, keywords are case-sensitive
(:FirstName my-map)
;= nil

;; creating a set
(def available-sizes #{ :small :medium :large })

;; test if a keyword is inside the set
(:small available-sizes)
;= :small
(:extra-small available-sizes)
;= nil
```

In Clojure they are often used to set options in functions or as function directives such as the :else of the cond function.

``` clojure
(def x -5)
(cond
   (>= x 0) "positive"
   :else    "negative )
;= negative
```

Even if they start with a colon (:), the colon is not part of the keyword itself, but it is just for definition.
Finally they can belong to a namespace, and to refer to the current namespace you can use a double colon (::).

``` clojure
:firstname
;= :firstname

::firstname
;= :user/firstname

;; keywords in the global space
;; and keywords in a specific namespace
;; are not the same. So make sure you
;; properly qualify your keywords

(identical? :user/firstname ::firstname)
;= true
(identical? :user/firstname :firstname)
;= false

;; the keyword function returns the keyword
;; associated to the specific string
(keyword "firstname")
;= :firstname

(identical? :user/firstname (keyword "firstname"))
;= false
(identical? :user/firstname (keyword "user" "firstname"))
;= true
```

Using the namespace can be useful to give a context to a specific keyword.

Related functions: [keyword](http://clojuredocs.org/clojure_core/clojure.core/keyword), [keyword?](http://clojuredocs.org/clojure_core/clojure.core/keyword_q), [find-keyword](http://clojuredocs.org/clojure_core/clojure.core/find-keyword), [name](http://clojuredocs.org/clojure_core/clojure.core/name).
