---
layout: page
title: Projects
permalink: /projects/
---

Here some of my Open Source projects which you might be interested into.


### Samsara


Samsara is a Real-Time analytics platform written in Clojure.

It's is a large scale analytics platform for BigData. With this
project I'm targeting users who feel the need of data analytics and
they want to keep their data, as supposed to use a third-party service
which it just shows you aggregated reports and not the raw data.

It can be used on both: website and mobile apps, but also in backend
services.  Samsara provides a end-to-end solution for collecting,
ingesting, processing, enrich, query and visualize your data leveraging
well established Open Source solutions like Kafka and ElasticSearch.

It has been used in large scale deployments processing _over 685
million events per day, and 25 million events per hour in peak time,
and over 500K clients_.

Because of it's flexible and scalable processing system you can build
easily real-time solutions for your products/services.  I've used it
to build a real-time recommendation system and other machine learning
solutions.

I'm looking to expand this project with more out-of-the-box machine
learning modules and to create a community behind the project.


  * **Github**: [https://github.com/samsara/samsara](https://github.com/samsara/samsara)
  * **Website**: [http://samsara-analytics.io/](http://samsara-analytics.io/)

---

### Where

`where` it's a small Clojure/ClojureScript library to write predicate
functions which are easier to read and easier to compose.

  * **Github**: [https://github.com/BrunoBonacci/where](https://github.com/BrunoBonacci/where)

---

### Safely

`safely` it's a Clojure library which embraces the declarative error
management idea.  The purpose of the library is to simply and
effectively handle retries declaratively making sure that in a large
distributed system these retries won't cause _self-similar mass
behavior_ and causing more arm than benefit.

  * **Github**: [https://github.com/BrunoBonacci/safely](https://github.com/BrunoBonacci/safely)

---

### dragonfiles

`dragonfiles` it's a Clojure tools to easily process files.  Most of
people are familiar with the Linux tool `awk`.  Although very powerful
it lack of expressiveness.  I found myself to have hundreds of
thousands of file to process and I was in the middle of deciding
whether shell scripting or Hadoop based solution was going to solve
the problem.  I wanted something easy as shell scripting, and not so
heavy as Hadoop. So I decided to write a small tool to cover this
middle ground where it would be too complex to develop `awk` scripts
but not yet so big enough to move to a BigData solution.  The tool
allow to easily define a processing function which is applied to every
file in input at once or line-by-line.  You can harness the power of
Clojure together with the rich Java/Clojure libraries ecosystem in a
command line environment.

_`dragonfiles` is still work-in-progress_ but already usable.

  * **Github**: [https://github.com/BrunoBonacci/dragonfiles](https://github.com/BrunoBonacci/dragonfiles)

---
