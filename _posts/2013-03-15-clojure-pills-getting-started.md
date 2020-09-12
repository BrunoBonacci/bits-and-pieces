---
layout: post
title: 'Clojure pills: Getting started'
date:   2013-03-15 22:00:00
categories: [development]
tags: [Clojure]
---

To get started with Clojure, you need the REPL. The REPL stands for Read Evaluate Print Loop and it is a console-like application where you can enter Clojure functions/expressions and get the result directly.

This is the best and simplest way to explore the language as you won’t need to setup and IDE and go through a edit/compile/run cycle. The REPL looks like an interpreter, however Clojure is NOT interpreted but compiled. The compilation will happen behind the scene without you noticing.

The easiest way to play with Clojure REPL without commitment is to use the online REPL: [http://tryclj.com/](http://tryclj.com/)

The second possibility is to download Clojure from [clojure.org](http://clojure.org/). In this case you’ll need few more steps:

``` bash
$ # donwload clojure-x.y.z.zip
$ unzip clojure-*.zip
$ cd clojure-*
$ java -jar clojure-*.jar
Clojure 1.5.1
user=>
```

When the `user=>` prompt appears you are in the REPL.

However, if you are serious about learning Clojure, I’ll suggest to use [Leiningen](http://leiningen.org/). It’s a build/automation tools such as Maven for java. To install Leiningen follow those steps:

``` bash
$ mkdir -p ~/bin
$ wget "https://raw.github.com/technomancy/leiningen/stable/bin/lein" -O ~/bin/lein
$ chmod +x ~/bin/lein
$ # ensure it is in the PATH
$ export PATH=~/bin:$PATH

$ lein new try-clojure
$ cd try-clojure

$ # you can see the project descriptor file
$ # and change the Clojure version to the one of your choice
$ vi project.clj
-------------8<----------------8<----------------8<----------
(defproject try-clojure "0.1.0-SNAPSHOT"
 :description "FIXME: write description"
 :url "http://example.com/FIXME"
 :license {:name "Eclipse Public License"
 :url "http://www.eclipse.org/legal/epl-v10.html"}
 :dependencies [[org.clojure/clojure "1.5.1"]])
-------------8<----------------8<----------------8<----------

$ # finally you can run the REPL
$ lein repl
...
user=>
Clojure hello world!:
```

In the REPL of your choice you can evaluate your first function:

``` clojure
user=> (println "Hello world!")
Hello world!
nil
user=>
```
