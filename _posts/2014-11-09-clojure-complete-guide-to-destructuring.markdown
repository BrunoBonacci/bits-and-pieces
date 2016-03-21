---
layout: post
title:  "The complete guide to Clojure destructuring."
date:   2014-11-16 10:00:00
categories: [development]
tags: [Clojure]
---

Destructuring is a simple, yet powerful feature of Clojure.
There are several ways in which you can leverage destructuring
to make your code cleaner, with less repetitions, and less bugs.

In this post I want to try to cover all possible ways you can
destructure Clojure's data structures. If I missed
anything please, drop me a message and I will include your feedback.

## TL;DR Destructuring cheatsheet
Jump at the bottom of the page if you just want to see a [destructuring cheatsheet](#cheatsheet).

## What destructuring is?

The simplest form of destructuring is the positional mapping of values
from a vector or a list.

Let's assume that we have a function which somehow returns the current
position in terms of latitude and longitude coordinates in the following
format: `[ lat lng ]`.


``` Clojure
(defn current-position []
  [51.503331, -0.119500])
```

Now assume we have another function which,
accepts two parameters and returns the geohash for a specific location.

``` Clojure
(defn geohash [lat lng]
   ;; this function take two separate values as params.
   ;; and it return a geohash for that position
)
```

Now if we wanted to get the geohash for our current position we would typically
do as follow:

``` Clojure
(let [coord (current-position)
      lat   (first coord)
      lng   (second coord)]
  (geohash lat lng))
```

Although this works, there is a lot of boilerplate code for just calling two functions. Destructuring allows you to separate a structured value into its costituent parts.
For example the following code is equivalent to the previous one.

``` Clojure
(let [[lat lng] (current-position)]
  (geohash lat lng))
```

Basically the returned value from `(current-position)` which is a structured value (vector), is getting **de-structured** into the mapping vector `[lat lng]` where the first value is assigned to the first element in the vector, the second to the second, and so on.

``` bash
[lat lng] (current-position)
    |             |
    V             V
[lat lng] [51.503331, -0.119500]


[51.503331, -0.119500]
     |          |
     V          V
   [lat        lng]

```

The destructuring can be used in any of the binding forms (`let`, `loop`, `binding`, etc) as well as funcation's parameters and return values.

Now that we understand what destructuring is, we can explore in which ways we can use it to simplify our code.


## Destructuring of lists, vectors and sequences.

All sequential data structures in Clojure be destructured in the same way.

``` Clojure
(let [[one two three] [1 2 3]]
  (println "one:" one)
  (println "two:" two)
  (println "three:" three))

(let [[one two three] '(1 2 3)]
  (println "one:" one)
  (println "two:" two)
  (println "three:" three))

(let [[one two three] (range 1 4)]
  (println "one:" one)
  (println "two:" two)
  (println "three:" three))

;; one: 1
;; two: 2
;; three: 3
```

All above s-expr print out the same result.

The example that follow applies in the same way to lists, vectors and sequences.
If you are not interested in all values you can capture only the ones you are
interested in and ignore the others by putting an **underscore** (`_`) as
a placeholder for its value.

``` Clojure
(let [[_ _ three] (range 1 10)]
  three)
;;=> 3
```

If you wish capture all the remaining values as a sequence, for example the numbers
from 4 to 9, you need to add an ampersand (`&`) and a symbol to bind to.


``` Clojure
(let [[_ _ three & numbers] (range 1 10)]
  numbers)
;;=> (4 5 6 7 8 9)
```

This is a good way to replace `first` and `rest` which often appear in `loop`/`recur` construct.

In some cases it is usefull or necessary to keep the full structured parameter as it was originally. Clojure in this case provides the clause `:as` followed by a symbol.

``` Clojure
(let [[_ _ three & numbers :as all-numbers] (range 1 10)]
  all-numbers)
;;=> (1 2 3 4 5 6 7 8 9)
```


## Maps destructuring.

No need to say, maps in Clojure are everywhere. If you pass a map as a parameter to a function,
or you return a map out of a function and you want to extract some of the map's field, then destructuring
is what you are looking for.

Let's go back to our geohashing of the current-position example (first exmaple),
if the function `current-position` rather than returning a vector of two elements
it returned a map, this is probably how you would write the code without destructuring.

``` Clojure
(defn current-position []
  {:lat 51.503331, :lng -0.119500})

(let [coord (current-position)
      lat   (:lat coord)
      lng   (:lng coord)]
  (geohash lat lng))
```


Again, nothing wrong with this code, but there is a lot of boilerplate stuff. Think what would happen if you have to extract ten properties.
Maps have two ways to destructure data.


``` Clojure
(let [{lat :lat, lng :lng} (current-position)]
  (geohash lat lng))
```

In this case you are telling to the destructuring process to do the following things:

   - *Of the returned map, put the content of the key `:lat` into a local var called `lat`*
   - *Of the returned map, put the content of the key `:lng` into a local var called `lng`*

But again, there is a lot of repetition. This form is useful in some context which will explore later,
however most commonly Clojure's map are destructured in the follwoing way.

``` Clojure
(let [{:keys [lat lng]} (current-position)]
  (geohash lat lng))
```


This form of destructuring is very common as it easily allows you to select which keys
are you interested in, however both map Destructuring methods allows you to retain the
entire map with the `:as` clause in the same way of the lists.

``` Clojure
(let [{lat :lat, lng :lng :as coord} (current-position)]
  (println "calculating geohash for coordinates: " coord)
  (geohash lat lng))


(let [{:keys [lat lng] :as coord} (current-position)]
  (println "calculating geohash for coordinates: " coord)
  (geohash lat lng))
```

From Clojure 1.6 you can also specify the keys as keywords and they
can even be namespaced. The following code snippet is equivalent to the previous

``` Clojure
(let [{:keys [:lat :lng] :as coord} (current-position)]
  (println "calculating geohash for coordinates: " coord)
  (geohash lat lng))
```


If your keys in your map are not Clojure's keywords, but strings then you
can use the `:strs` instead of `:keys`.


``` Clojure
(let [{:strs [lat lng] :as coord} {"lat" 51.503331, "lng" -0.119500}]
  (println "calculating geohash for coordinates: " coord)
  (geohash lat lng))
```


Another option, but not very much used is to have Clojure symbols as keys of your map.
In this case you should use `:syms` instead of `:keys`

``` Clojure
(let [{:syms [lat lng] :as coord} {'lat 51.503331, 'lng -0.119500}]
  (println "calculating geohash for coordinates: " coord)
  (geohash lat lng))
```



## Destructuring maps with default values

Map destructuring with default values is a very powerful feature.
Assume that you have function `connect-db` which takes as input
a map with your db configuration.
Typically there are a lot of parameters involved, assume that you want
to be able to provide default for all or most of the values. One way would
be to put the default values in a map and then merge the parameters with
the default values. The destructuring offers an easier way to do this.

``` Clojure
(defn connect-db [{:keys [host port db-name username password]
                   :or   {host     "localhost"
                          port     12345
                          db-name  "my-db"
                          username "db-user"
                          password "secret"}
                   :as cfg}]
   (println "connecting to:" host "port:" port "db-name:" db-name
            "username:" username "password:" password))

(connect-db {:host "server"})
;; connecting to: server port: 12345 db-name: my-db username: db-user password: secret

(connect-db {:host "server" :username "user2" :password "Passowrd1"})
;; connecting to: server port: 12345 db-name: my-db username: user2 password: Passowrd1
```

Notice how the default values are injected in the destructured vars only for the keys
which are not provided.

Lastly, you can combine the map destructuring with default values with variadic
parameters to have functions with default parameters.

If in our example we want to force the user of the `connect-db` function
to provide at least the `host` where to connect to, but everything else
is optional we can write the function as follow:

``` Clojure
(defn connect-db [host ; mandatory parameter
                  & {:keys [port db-name username password]
                     :or   {port     12345
                            db-name  "my-db"
                            username "db-user"
                            password "secret"}}]
   (println "connecting to:" host "port:" port "db-name:" db-name
            "username:" username "password:" password))

(connect-db "server")
;; connecting to: server port: 12345 db-name: my-db username: db-user password: secret

(connect-db "server" :username "user2" :password "Passowrd1")
;; connecting to: server port: 12345 db-name: my-db username: user2 password: Passowrd1
```

## Maps destructuring with custom key names

Sometimes it is useful or necessary to destructure maps with a local variable name
which name is different than the key name.

``` Clojure
(def contact
  {:firstname "John"
   :lastname  "Smith"
   :age       25
   :phone     "+44.123.456.789"
   :emails    "jsmith@company.com"})

(let [{firstname :firstname age :age} contact]
  (str "Hi, I'm " firstname " and I'm " age " years old."))
;;=> "Hi, I'm John and I'm 25 years old."

(let [{name :firstname years-old :age} contact]
  (str "Hi, I'm " name " and I'm " years-old " years old."))
;;=> "Hi, I'm John and I'm 25 years old."

```

As shown in this second example you can define local var with a name
that is different than the key. For example if we have to calculate
the distance between two points in a Cartesian plane we can build a
function as follow:


``` Clojure
(defn distance [{x1 :x y1 :y} {x2 :x y2 :y}]
  (let [square (fn [n] (*' n n))]
    (Math/sqrt
     (+ (square (- x1 x2))
        (square (- y1 y2))))))

(distance {:x 3, :y 2} {:x 9, :y 7})
;;=> 7.810249675906654
```



## Destructuring maps as key-value pairs

Even if maps aren't stricly speaking sequences, you can easily build a sequence out of a map. Once the sequence is built, the items are key-value pairs which can be destructured as any other vector or list. This is very common when `mapping` over a map.

``` Clojure
(def contact
  {:firstname "John"
   :lastname  "Smith"
   :age       25
   :phone     "+44.123.456.789"
   :emails    "jsmith@company.com"})

(map (fn [[k v]] (str k " -> " v)) contact)
;;(":age -> 25"
;; ":lastname -> Smith"
;; ":phone -> +44.123.456.789"
;; ":firstname -> John"
;; ":emails -> jsmith@company.com")
```



## Nested destructuring

It also possible to do nested destructing. Here is how you can capture content from a nested vector or list.

``` Clojure
;; source: wikipedia
(def inventor-of-the-day
  ["John" "McCarthy"
   "1927-09-04"
   "LISP"
   ["Turing Award (1971)"
    "Computer Pioneer Award (1985)"
    "Kyoto Prize (1988)"
    "National Medal of Science (1990)"
    "Benjamin Franklin Medal (2003)"]])

(let [[firstname lastname _ _ [first-award & other-awards]] inventor-of-the-day]
  (str firstname ", " lastname "'s first notable award was: " first-award))
;;=> "John, McCarthy's first notable award was: Turing Award (1971)"
```


Destructuring nested maps seems a bit more complicated:

``` Clojure
(def contact
  {:firstname "John"
   :lastname  "Smith"
   :age       25
   :contacts {:phone "+44.123.456.789"
             :emails {:work "jsmith@company.com"
                      :personal "jsmith@some-email.com"}}})

;; Just the top level
(let [{lastname :lastname} contact]
  (println lastname ))
;; Smith

;; One nested level
(let [{lastname :lastname
       {phone :phone} :contacts} contact]
  (println lastname phone))
;; Smith +44.123.456.789

(let [{:keys [firstname lastname]
       {:keys [phone] } :contacts} contact]
  (println firstname lastname phone ))
;; John Smith +44.123.456.789

(let [{:keys [firstname lastname]
       {:keys [phone]
        {:keys [work personal]} :emails } :contacts} contact]
  (println firstname lastname phone work personal))
;;John Smith +44.123.456.789 jsmith@company.com jsmith@some-email.com
```


## Less common destructuring forms

There are some other forms of destructuring which can be used in particular
situations, they are not very common, however it is worth to mention them.

### Destructuring vectors by keys

Clojure's vectors and maps share a lot of commonalities. They are both implemented via
[Hash array mapped trie (HAMT)](http://en.wikipedia.org/wiki/Hash_array_mapped_trie)
(you can find more about their implementation on Ref.1[^1], Ref.2[^2]),
both support the retrieval by key (or index for vectors)
via the [`get`](https://clojuredocs.org/clojure.core/get) function.

For this reason you can use map's destructuring methods to destructure vectors.
This method might be useful when you have to extract only few keys in high indices.
For example assume that you have a vector with 500 elements and you want to
extract only the elements at index 100 and 200.

``` Clojure
(let [{one 1 two 2} [0 1 2]]
  (println one two))
;; 1 2

(let [{v1 100 v2 200} (apply vector (range 500))]
  (println v1 v2))
;; 100 500
```


### Set's destructuring

Sets are just like maps, but the key and value are set to the same value.
This it can be useful to test whether an element is part of a set.

``` Clojure
(let [{:strs [blue white black]} #{"blue" "white" "red" "green"}]
  (println blue white black))
;; blue white nil
```

Set's destructuring can be useful when you have a function which can optionally accepts flags
to modify its behaviour. For example let's consider the an hypothetical function `ls`
which behave like the unix command [`/bin/ls`](http://man7.org/linux/man-pages/man1/ls.1.html)
this function takes a path and an optional set of flags.

``` Clojure
(defn ls [path & flags]
  (let [{:keys [all long-format human-readable sort-by-time]} (set flags)]
    ;; now you can test your flags
    (when long-format (comment do someting))
    ;; ....
    ))
```

Notice that we are creating a Clojure set out of the `flags` sequence,
and then using destructuring to capture the individual flags.

## Conclusion

As we seen, value destructuring is a powerful Clojure's feature. It can eliminate
loads of boilerplate and repetitions which, often, lead to bugs.
In the writing of this post I've looked to the excellent Jay Fields' post[^3],
some of the Clojure's documentation[^4], I do suggest whoever is looking for more examples to have a look to those links.
At first, destructuring might seems to complicate the syntax and the readability,
however once you master the syntax, you'll see that the code becomes clearer
and event more readable.

## Clojure destructuring cheatsheet<a name="cheatsheet">&nbsp;</a>
``` Clojure
;; all the following destructuring forms can be used in any of the
;; Clojure's `let` derived bindings such as function's parameters,
;; `let`, `loop`, `binding`, `for`, `doseq`, etc.

;; list, vectors and sequences
[zero _ _ three & four-and-more :as numbers] (range)
;; zero = 0, three = 3, four-and-more = (4 5 6 7 ...),
;; numbers = (0 1 2 3 4 5 6 7 ...)

;; maps and sets
{:keys [firstname lastname] :as person} {:firstname "John"  :lastname "Smith"}
{:keys [:firstname :lastname] :as person} {:firstname "John"  :lastname "Smith"}
{:strs [firstname lastname] :as person} {"firstname" "John" "lastname" "Smith"}
{:syms [firstname lastname] :as person} {'firstname "John"  'lastname "Smith"}
;; firstname = John, lastname = Smith, person = {:firstname "John" :lastname "Smith"}

;; maps destructuring with different local vars names
{name :firstname family-name :lastname] :as person} {:firstname "John"  :lastname "Smith"}
;; name = John, family-name = Smith, person = {:firstname "John" :lastname "Smith"}

;; default values
{:keys [firstname lastname] :as person
 :or {firstname "Jane"  :lastname "Bloggs"}} {:firstname "John"}
;; firstname = John, lastname = Bloggs, person = {:firstname "John"}

;; nested destructuring
[[x1 y1] [x2 y2] [_ _ z]]  [[2 3] [5 6] [9 8 7]]
;; x1 = 2, y1 = 3, x2 = 5, y2 = 6, z = 7

{:keys [firstname lastname] {:keys [phone]} :contact} {:firstname "John" :lastname "Smith"
                                                       :contact {:phone "0987654321"}}
;; firstname = John, lastname = Smith, phone = 0987654321
```


---


For this article I've used:

  - Clojure 1.6.0

References:

   [^1]: [http://hypirion.com/musings/understanding-persistent-vector-pt-1](http://hypirion.com/musings/understanding-persistent-vector-pt-1)
   [^2]: [https://idea.popcount.org/2012-07-25-introduction-to-hamt/](https://idea.popcount.org/2012-07-25-introduction-to-hamt/)
   [^3]: [http://blog.jayfields.com/2010/07/clojure-destructuring.html](http://blog.jayfields.com/2010/07/clojure-destructuring.html)
   [^4]: [Clojure Special Forms](http://clojure.org/special_forms#Special Forms--Binding Forms (Destructuring)-Vector binding destructuring)
