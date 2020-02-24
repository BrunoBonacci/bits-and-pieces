---
layout: page
title: Projects
permalink: /projects/
---

Here some of my Open Source projects which you might be interested into.

### safely

![active](https://img.shields.io/badge/development-active-brightgreen)
![stable](https://img.shields.io/badge/API-stable-brightgreen)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![use-it](https://img.shields.io/badge/should--I--use--it%3F-Definitely-blue)

`safely` is a Clojure Circuit-Breaker and retry library with a
*declarative approach*.  The purpose of the library is to simply and
effectively handle retries declaratively making sure that in a large
distributed system these retries won't cause _self-similar mass
behavior_ causing more harm than benefit. The circuit breaker
is implemented fully in Clojure and offers good features for
observability..

  * **Github**: [https://github.com/BrunoBonacci/safely](https://github.com/BrunoBonacci/safely)

---


### 1Config

![active](https://img.shields.io/badge/development-active-brightgreen)
![stable](https://img.shields.io/badge/API-stable-brightgreen)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![use-it](https://img.shields.io/badge/should--I--use--it%3F-Definitely-blue)

**1Config is A tool and a library to manage application secrets and
configuration safely and effectively.**

Here some of the key-points and advantages:

  * Easy way to retrieve and manage configuration for your AWS deployed services
  * Compatible with AWS Lambdas as well
  * AWS KMS envelope encryption for extra security (same as S3-SSE, EBS and RDS)
  * Support for key-rotation
  * Highly available (as available as DynamoDB + KMS)
  * Support for multiple environments in the same AWS account
  * Support for multiple services in the same environment
  * Support for multiple concurrent versions of the same service
  * Zero config approach (or at most 1 config `;-)`)
  * *Anti-tampering checks for configuration entries* (entries can't be manipulated manually)
  * Supports Clojure, Java, Groovy, and other JVM languages (more to come)
  * Command line tool for managing changes to the configuration
  * Graphical User interface for managing changes to the configuration
  * Support for local development (outside AWS)
  * Highly-configurable and secure authorization.

It has a very strong security model and very a simple but powerful
API.  Because it offers a Clojure and Java client you can read the
configuration directly from your application without using
intermediate storage such host filesystem, environment variables etc.
*The best way to pass certificates and other secrets to your
applications. Best way to manage application configuration on AWS in
general.*

  * **Github**: [https://github.com/BrunoBonacci/1config](https://github.com/BrunoBonacci/1config)

---


### μ/log

![active](https://img.shields.io/badge/development-active-brightgreen)
![evolving](https://img.shields.io/badge/API-evolving-green)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![check-it-out](https://img.shields.io/badge/should--I--use--it%3F-check--it--out%21-blue)

`μ/log` is a Clojure library for structured event logging.
Contrarily, most of the existing log library which focus on logging
human readable messages, ***μ/log*** offers APIs to log events and
data-points. Human readable messages often encode data which it is then
sent to centralized logging systems and loads of effort is put to
extract useful information out of the string message. ***μ/log***
allow to send data directly and in a safe manner, enabling post
processing and query aggregation in ways that other systems can't.

On top of ***μ/log***, I'm also building ***μ/trace***, a micro-tracing library
which allows to extends the basic event-logging capabilities with
distributed tracing information.

  * **Github**: [https://github.com/BrunoBonacci/mulog](https://github.com/BrunoBonacci/mulog)

---

### Optimus

![inactive](https://img.shields.io/badge/development-inactive-inactive)
![stable](https://img.shields.io/badge/API-stable-brightgreen)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![use-it](https://img.shields.io/badge/should--I--use--it%3F-Definitely-blue)


`Optimus` is a key-value store which I co-designed and developed while
working at Trainline.com. It has customizable backends, it defaults to
DynamoDB and it offers the ability to load millions of records and
atomically publish them. This is used to publish Machine Learning
models, or pre-computed values like recommendations in a way that the
consumer will either see the new set of values or the old set of
values, but never some values from two different partial updates. It
provides also APIs to quickly and atomically rollback to a previous
published version in case you realize that the new Machine Learning
model isn't performing as you expect.

  * My extensions **Github**: [https://github.com/BrunoBonacci/optimus](https://github.com/BrunoBonacci/optimus)
  * Published initially under **Github**: [https://github.com/trainline/optimus](https://github.com/trainline/optimus)

---

### where

![active](https://img.shields.io/badge/development-active-brightgreen)
![stable](https://img.shields.io/badge/API-stable-brightgreen)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![use-it](https://img.shields.io/badge/should--I--use--it%3F-Definitely-blue)

`where` is a small Clojure/ClojureScript library to write predicate
functions which are easier to read and easier to compose.  It supports
a number of built-in comparators which are `nil` safe and they support
case insensitive checks.

  * **Github**: [https://github.com/BrunoBonacci/where](https://github.com/BrunoBonacci/where)

---

### Samsara

![inactive](https://img.shields.io/badge/development-inactive-inactive)
![stable](https://img.shields.io/badge/API-stable-inactive)
![production](https://img.shields.io/badge/production-used-brightgreen)
![hold-on](https://img.shields.io/badge/should--I--use--it%3F-Hold--on-orange)

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
  * **Blog**: [Designing Samsara](http://blog.brunobonacci.com/2016/06/20/designing-samsara/)

---


### clj-sophia

![inactive](https://img.shields.io/badge/development-inactive-inactive)
![feature-complete](https://img.shields.io/badge/API-feature--complete-brightgreen)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![use-it](https://img.shields.io/badge/should--I--use--it%3F-Definitely-blue)

An idiomatic Clojure driver for [Sophia DB](http://sophia.systems/).
Sophia is RAM-Disk hybrid storage designed to provide best possible
on-disk performance without degradation in time.  Sophia is an
embedded key/value store which implements a LSM storage system. Very
fast and fully ACID (Serialized Snapshot Isolation - SSI)
transactional support..

  * **Github**: [https://github.com/BrunoBonacci/clj-sophia](https://github.com/BrunoBonacci/clj-sophia)

---

### ring-boost

![inactive](https://img.shields.io/badge/development-inactive-inactive)
![mvp](https://img.shields.io/badge/API-mvp-yellow)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![check-it-out](https://img.shields.io/badge/should--I--use--it%3F-check--it--out%21-blue)


A library to boost performances of Clojure web applications with
off-heap serverside caching. Serverside caching is uniquely
positionated for effective caching it does NOT require all clients to
implement caching directives on the client side.  The cached payload
is stored off-heap and on disk so that it doesn't put more pressure on
the Garbage Collector. Since the cache data is stored on disk it avoid
the problem of a cold-restart with and empty cache. The caching logic
can be completely customized to tailor your needs.

  * **Github**: [https://github.com/BrunoBonacci/ring-boost](https://github.com/BrunoBonacci/ring-boost)

---


### TrackIt!

![maintenance-only](https://img.shields.io/badge/development-maintenance--only-yellow)
![stable](https://img.shields.io/badge/API-stable-brightgreen)
![production](https://img.shields.io/badge/production-in--use-brightgreen)
![use-it](https://img.shields.io/badge/should--I--use--it%3F-Check%20%CE%BC%2Flog-blue)


`TrackIt!` allows you to instrument your code and record useful metrics
and publish those metrics to a number of backend systems for indexing
and visualization, such as:

  - Console
  - Ganglia
  - Graphite
  - Statsd
  - Infuxdb
  - Reimann
  - NewRelic
  - AWS Cloudwatch
  - Prometheus
  - JMX Beans

It is based on the popular [Dropwizard's Metrics](https://metrics.dropwizard.io/) library,
with a Clojure idiomatic and developer friendly API.

  * **Github**: [https://github.com/samsara/trackit](https://github.com/samsara/trackit)

If you thinking to use this, maybe you should check
[**`μ/log`**](https://github.com/BrunoBonacci/mulog) out first!

---

### Clojure meets GraalVM

GraalVM is really exciting news for Clojure. Particularly the ability
to build **native images**. In this project I've tried to collect all
the info to build native-images for Clojure based projects.  Building
complex projects in GraalVM's *native-image* can be quite challenging.
Therefore, I've tried to take common libraries and build *hello-world*
style projects and build them with GraalVM's *native-image* and
document challenges, parameters to use and solution to common
problems. If you are interested in native images for your Clojure
projects this is a good place to start.

  * **Github**: [https://github.com/BrunoBonacci/graalvm-clojure](https://github.com/BrunoBonacci/graalvm-clojure)

---


### dragonfiles

![inactive](https://img.shields.io/badge/development-inactive-inactive)
![mvp](https://img.shields.io/badge/API-mvp-yellow)
![not-in-use](https://img.shields.io/badge/production-not--in--use-inactive)
![hold-on](https://img.shields.io/badge/should--I--use--it%3F-Hold--on-orange)


`dragonfiles` is a Clojure tools to easily process files.  Most of
people are familiar with the Linux tool `awk`.  Although very powerful
it lack of expressiveness.  I found myself having to process several
hundreds of thousands of small files and I was trying to decide
whether it would have been better to build a shell-scripting solution
or a Hadoop-based solution. I wanted something easy as shell
scripting, and not so heavy as Hadoop. So I decided to write a small
tool to cover this middle ground where it would be too complex to
develop `awk` scripts but not yet so big enough to move to a BigData
solution.  The tool allow to easily define a processing function which
is applied to every file in input at once or line-by-line.  You can
harness the power of Clojure together with the rich Java/Clojure
libraries ecosystem in a command line environment.

_`dragonfiles` is still work-in-progress_ but already usable if you really want.

  * **Github**: [https://github.com/BrunoBonacci/dragonfiles](https://github.com/BrunoBonacci/dragonfiles)

---
