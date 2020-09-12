---
layout: post
title:  "Cascalog by examples (part 1)"
date:   2014-06-01 17:45:25
categories: [development, BigData]
tags: [Cascalog, Clojure, BigData, Pig, Hive, Hadoop]
---

In the past 2-3 years I've been using a number of different
technologies on top of Hadoop for querying and processing BigData.

All of them have advantages and drawbacks, some are easier to start
with, others looks more familiar. The one I'm personally settled with
is Cascalog.

In this post I will make examples of queries using
[Apache Pig](http://pig.apache.org/docs/r0.12.1/) and SQL for
comparison. The examples will start with the most basic query and
step-by-step I will add a new elements to it showing how the SQL
compares to Pig and how both compare to Cascalog.

# Why Cascalog?
There are two broad categories of work that you
normally do with your data: **querying and transforming**, some tools
are better suited for querying such as SQL some others have features
which allow you to perform custom transformation of your data.

Cascalog, in my opinion, is a superior approach for both for a number
of reasons. Firstly it's a Clojure DSL. Manipulating data with Clojure
is by far easier than most of general purpose languages (Java, Python,
C, Ruby, etc). I'll explain my claim in another post, but will suffice
to say that it has hundreds of functions to manipulate data, it's on
the JVM so you can leverage any existing library and the language it's
[homoiconic](http://en.wikipedia.org/wiki/Homoiconicity) which means
that the source code is made of the same data structures (lists) which
you can use for your data, and you can use the same functions that
manipulate your data to manipulate your source code at compile time.

In languages like Pig and Hive, in order to make complex manipulation
of your data you have to write _User Defined Functions
(**UDF**)_. UDFs are a great way to extend the basic functionality,
however for Hive and Pig you have to use a different language to write
your UDFs as the basic SQL or Pig Latin languages have only a handful
of functions and they lack of basic control structures. Both they
offer the possibility to write UDFs in a number of different languages
(which is great), however this requires a programming paradigm switch
by the
developer. [Pig allows to write UDFs](http://pig.apache.org/docs/r0.12.1/udf.html)
in Java, Jython, JavaScript, Groovy, Ruby and Python, for Hive you
need to write then in Java
[(good article here)](http://snowplowanalytics.com/blog/2013/02/08/writing-hive-udfs-and-serdes/). I
won't make the example of UDFs in Java as the comparison won't be
fair, _life is too short to write them in Java_, but let's assume that
you want to write a UDF for Pig and you want to use Python. If you go
for the JVM platform version (Jython) you won't be able to use
existing modules coming from Python ecosystem (unless they are in pure
Python). Same for Ruby and Javascript. If you decide to use Python you
will have the setup burden of installing Python and all the modules
that you intend to use in every Hadoop task node. So, you start with a
language such as Pig Latin or SQL, you have to write, compile and
bundle UDFs in a different language, you are constrained to use only
the plain language without importing modules or face the extra
burden of additional setup and, as if is not enough, you have to
smooth the type difference between the two languages during their
communication back and forth with the UDF. For me that's enough to say
that we can do better than that. Cascalog is a Clojure DSL, so your
main language is Clojure, your custom functions are Clojure, the data
are represented in Clojure data types, and the runtime is the JVM,
no-switch required, no additional compilation required, no
installation burden, and you can use all available libraries in the
JVM ecosystem.

There are other reasons for which Cascalog is better than Pig, Hive et
al. Just to mention few you have a very easy and high level query
language which is based on logic programming and rule inference, you
can and it is encouraged to write sub-queries and reuse
them. Therefore you can write complex processing by composing simple
sub-queries. Cascalog comes with a framework to test your queries and
jobs while other tools have very little to support testing. If you
have done any non-trivial job with Hadoop you know the pain of running
job over and over and have to fix one error at the time. The
integration of Midje (a Clojure testing tool) with Cascalog enables
you to write completely in-memory tests which will behave like in the
Hadoop cluster. Finally probably one of the most important feature,
you have a REPL (Read, Eval, Print Loop) which enables you to explore
your data in a more interactive way.

Another big reason for using Cascalog is that you can reuse your query
and transformation in both: a batch process or a real-time streaming
solution. In fact Cascalog is just an higher lever abstraction on top
of Cascading. Cascalog allows you to compile your query into a lower
level concrete execution plan, and you could also write a custom
compiler to generate an execution plan for a tool which you want to
use. For example Cascalog query can be compiled to MapReduce jobs, to
SQL or Apache Storm.

In this post I won't be able to cover all those topics but I will try
to give a good introduction to the basic querying capabilities. I will
try to write a follow up post with more advanced use.

# Stop talking and let me see some code...

To start you will need to install [Leiningen](http://leiningen.org/),
then you can clone the repo which contains the data used for this post
and the query samples.

``` bash
git clone https://github.com/BrunoBonacci/cascalog-examples.git
cd cascalog-examples
lein repl
nREPL server started on port 53433 on host 127.0.0.1
REPL-y 0.2.1
Clojure 1.5.1
    Docs: (doc function-name-here)
          (find-doc "part-of-name-here")
  Source: (source function-name-here)
 Javadoc: (javadoc java-object-or-class-here)
    Exit: Control+D or (exit) or (quit)
 Results: Stored in vars *1, *2, *3, an exception in *e

user=>
```

Once the REPL is started you can run:

``` clojure
(use 'cascalog-examples.data)
(use 'cascalog.api)
(require '[cascalog.logic.ops :as c])
```

Which will load the sample dataset and the Cascalog APIs.

This will load two taps (Cascalog data sources) one called `USERS` and
the second one called `SCORES`. At this point let's see how the sample
data looks like:

``` clojure
(take 5 USERS)
;=> (["Kiayada Wyatt" "kiayada33" 33 "France" true]
;    ["Dominic Ochoa" "dominic43" 72 "United Kingdom" false]
;    ["Cherokee Hammond" "cherokee10" 22 "Russia" false]
;    ["Gemma Foley" "gemma36" 28 "Italy" true]
;    ["Ginger Garcia" "ginger55" 28 "India" false])

(count USERS)
;=> 500
```

_**NOTE: this data is randomly generated, including names, ages, scores and countries.**_

The Cascalog data format is based on
[tuples](http://cascalog.org/articles/getting_started.html#toc_10). In
the above example we have the first 5 records which each contains 5
tuples which are: _name, user, age, country, active_ and there are 500
users in total.

The `SCORES` dataset looks like this:

``` clojure
(take 5 (shuffle SCORES))
;=> (["jorden78" "Tetris" 2875]
;    ["noelle32" "Packman" 9389]
;    ["celeste17" "Arkanoid" 3248]
;    ["nadine28" "Packman" 582]
;    ["austin60" "Street Fighter" 3907])

(count SCORES)
;=> 6000
```

Now you are good to go.

I will show the same query in SQL then Pig and finally Cascalog.

---

## Show all records
A simple projection of fields and of course
you can change the disposition and
the number of fields in the projection side

### SQL
``` sql
SELECT name, user, age, country, active
  FROM USERS;
```


### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
DUMP users;
```


### Cascalog
``` clojure
(?<- (stdout)
     [?name ?user ?age ?country ?active]
     (USERS ?name ?user ?age ?country ?active))
```

Here Cascalog adds an implicit reduce step to remove duplicates.
If we really wish to have the same query as SQL and Pig we should
add `(:distinct false)` on our Cascalog query.

In reality the above query is split in to parts:
one is the actual query the second part is the
command to execute it and tell Cascalog where
to put the output.

  - 1) query

``` clojure
(<- [?name ?user ?age ?country ?active]
    (USERS ?name ?user ?age ?country ?active))
```

  - 2) execution

``` clojure
(?- (output) query)
```

for this reason we encapsulate the execution
into a Clojure function `run<-`
which we'll use to run our queries.

``` clojure
(defn run<- [query]
  (?- (stdout) query))
```

This is come comparable to the SQL statement

``` clojure
(run<-
 (<- [?name ?user ?age ?country ?active]
     (USERS ?name ?user ?age ?country ?active)))
```

---

## Simple filter
In this case we apply a simple filter on a field
we want to see all active users

### SQL
``` sql
SELECT name, user, age, country, active
  FROM USERS
 WHERE active = true;
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
out = FILTER users BY active == true;
DUMP out;
```

### Cascalog
``` clojure
(run<-
 (<-  [?name ?user ?age ?country ?active]
      (USERS ?name ?user ?age ?country ?active)
      (= ?active true)))
```

---

## Additional filters
Now we can see how easy is to add multiple filters

### SQL
``` sql
SELECT name, user, age, country, active
  FROM USERS
 WHERE active = true
   AND country = "India";
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
out = FILTER users BY active == true AND country == 'India';
DUMP out;
```

### Cascalog
``` clojure
(run<-
 (<-
  [?name ?user ?age ?country ?active]
  (USERS ?name ?user ?age ?country ?active)
  (= ?active true)
  (= ?country "India")))
```

---

## OR condition

Expressing OR conditions is a bit more
complicated. In Clojure #'or is a macro
not a function, so is not composable as function,
and need to be wrapped.

### SQL
``` sql
SELECT name, user, age, country, active
  FROM USERS
 WHERE active = true
    OR age >= 70;
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
out = FILTER users BY active == true OR age >= 70;
DUMP out;
```

### Cascalog
``` clojure
(deffilterfn active-or-senior [active age]
  (or active
      (>= age 70)))

(run<-
 (<-
  [?name ?user ?age ?country ?active]
  (USERS ?name ?user ?age ?country ?active)
  (active-or-senior :< ?active ?age)))
```

---

## Simple transformation

The optional `:<` keyword denotes
input fields to the function
the output can be then placed into field
with `:>` for example if we want to perform a simple
transformation on a field, such as making
the username uppercase we can run

### SQL
``` sql
SELECT name, UPPER(user), age, country, active
  FROM USERS;
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
out = FOREACH users GENERATE name, UPPER(user), age, country, active;
DUMP out;
```

### Cascalog
``` clojure
(run<-
 (<-
  [?name ?user2 ?age ?country ?active]
  (USERS ?name ?user ?age ?country ?active)
  (clojure.string/upper-case :< ?user :> ?user2)))
```

of course you can map over any custom clojure function,
but in this case you will have to use one of the special def
like `defmapfn`. The def* macros from Cascalog they add a bit
of info into the the var so that cascalog will know how
to distribute your custom function in the jar for hadoop

### Cascalog
``` clojure
(defmapfn my-upper [s]
  (clojure.string/upper-case s))

(run<-
 (<-
  [?name ?user2 ?age ?country ?active]
  (USERS ?name ?user ?age ?country ?active)
  (my-upper :< ?user :> ?user2)))
```

---

## Aggregations

Some simple aggregations over the entire dataset

### SQL
``` sql
SELECT count(*), avg(age)
  FROM USERS;
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
g = GROUP users ALL;
out = FOREACH g GENERATE COUNT(users), AVG(users.age);
DUMP out;
```

### Cascalog
``` clojure
(run<-
 (<-  [?count ?average]
      (USERS ?name ?user ?age ?country ?active)
      (c/count :> ?count)
      (c/avg :< ?age :> ?average)))
```

---

## Group aggregations

Now aggregation over a group

### SQL
``` sql
SELECT count(*), avg(age), country
  FROM USERS
 GROUP BY country;
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
g = GROUP users BY country;
out = FOREACH g GENERATE COUNT(users), AVG(users.age), group;
DUMP out;
```


### Cascalog
``` clojure
(run<-
 (<-  [?count ?average ?country]
      (USERS ?name ?user ?age ?country ?active)
      (c/count :> ?count)
      (c/avg :< ?age :> ?average)))
```


*NOTE: this is unintuitive.*
In this case we just added a field in the projection
and nothing else and magically the aggregation is now
over a group. Where is the `GROUP BY` equivalent clause?

In Cascalog the `GROUP BY` is implicit ([as explained here](http://cascalog.org/articles/getting_started.html#toc_12)).

Let's find the number of active users by country

### SQL
``` sql
SELECT count(*), country
  FROM USERS
 WHERE active = true
 GROUP BY country;
```


### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
a = FILTER users BY active == true;
g = GROUP a BY country;
out = FOREACH g GENERATE COUNT(a), group;
DUMP out;
```


### Cascalog
``` clojure
(run<-
 (<-     [?count ?country]
         (USERS ?name ?user ?age ?country ?active)
         (= ?active true)
         (c/count :> ?count)))
```

---

## Post aggregations filtering (`HAVING`)

If you want to find the number of active users by country
and display only those who have 25 or more active users


### SQL
``` sql
SELECT count(*) as count, country
  FROM USERS
 WHERE active = true
 GROUP BY country
HAVING count >= 25;
```


### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
a = FILTER users BY active == true;
g = GROUP a BY country;
f = FOREACH g GENERATE COUNT(a) as count, group as country;
out = FILTER f BY count >= 25;
DUMP out;
```


### Cascalog
``` clojure
(run<-
 (<-     [?count ?country]
         (USERS ?name ?user ?age ?country ?active)
         (= ?active true)
         (c/count :> ?count)
         (>= ?count 25)))
```

---

## Sorting

to sort the result set we can use the :sort predicate

### SQL
``` sql
SELECT name, user, age, country, active
  FROM USERS
 ORDER BY age DESC;
```


### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
out = ORDER users BY age DESC;
DUMP out;
```


### Cascalog
Global sorting is not very common in big data,
most of the times you will sort by group.
However if you have to sort the entire dataset
you have to write a function which takes
a query and a list of fields to sort by.

In this case Cascalog it makes it more difficult that
any other tool :-(, you have to write a custom function.
Luckily you can write it once and reuse it many times.

``` clojure
(require '[cascalog.logic.vars :as v])
(import 'cascalog.ops.IdentityBuffer)

(defn global-sort [sq fields desc?]
  (let [out-fields (get-out-fields sq)
        new-out-fields (v/gen-nullable-vars (count out-fields))]
    (<- new-out-fields
        (sq :>> out-fields)
        (:sort :<< fields)
        (:reverse desc?)
        ((IdentityBuffer.) :<< out-fields :>> new-out-fields))))

(run<-
 (global-sort
  (<- [?name ?user ?age ?country ?active]
      (USERS ?name ?user ?age ?country ?active))
  ["?age"] true))
```

---

## Top-N by group

Here we want to find the two oldest active user per country

To do this in SQL we need to do some serious SQL kung-fu!!
Frankly it's unreadable, none could easily say what this
SQL query does.

### SQL
``` sql
    SELECT u.name, u.user, u.age, u.country
     FROM USERS as u
LEFT JOIN USERS as u2
       ON u.country = u2.country
      AND u.age <= u2.age
    WHERE  u.active = true
      AND u2.active = true
 GROUP BY u.country, u.user
   HAVING count(*) <= 2;
```
**NOTE: this O(n^2) very bad!!!**

Top-N by group is a rather complicated matter in SQL,
here you can find some alternative approaches
[http://www.xaprb.com/blog/2006/12/07/how-to-select-the-firstleastmax-row-per-group-in-sql/](http://www.xaprb.com/blog/2006/12/07/how-to-select-the-firstleastmax-row-per-group-in-sql/)


The Pig version is a bit more intuitive:

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
a = FILTER users BY active == true;
g = GROUP a BY country;
out = FOREACH g {
   s = ORDER a by age DESC;
   l = LIMIT s 2;
   GENERATE FLATTEN(l);
}
DUMP out;
```


However in Cascalog it's very easy:
you make a projection by country (which creates a group)
and in the group you sort by age, reverse
and take the top 2

### Cascalog
``` clojure
(run<-
 (<-    [?name1 ?user1 ?age1 ?country]
        (USERS ?name ?user ?age ?country ?active)
        (= ?active true)
        (:sort ?age)
        (:reverse true)
        ((c/limit 2) ?name ?user ?age :> ?name1 ?user1 ?age1)))
```

---

## Joins


If we want to display the real name of each user together
with the game they played and their score we will need to:

### SQL
``` sql
    SELECT u.name, s.game, s.score
     FROM USERS as u, SCORES as s
    WHERE u.user = s.user;
```


### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
scores = LOAD './data/scores.tsv' USING PigStorage()
        AS (user:chararray, game:chararray, score:int);
j = JOIN users BY user, scores by user;
out = FOREACH j GENERATE users::name, scores::game, scores::score;
DUMP out;
```


In order to join multiple datasources you need just to add their tap
and by mentioning the same field name on multiple sources
Cascalog will automatically infer the join key.


### Cascalog
``` clojure
(run<-
 (<-    [?name ?game ?score]
        (USERS  ?name ?user ?age ?country ?active)
        (SCORES ?user ?game ?score)))
```



If we want to display all user which are younger than 15
and have more than 6000 points playing Tetris we will need to:

### SQL
``` sql
    SELECT s.score, u.name, u.age, u.country
      FROM USERS u, SCORES s
     WHERE u.user = s.user
       AND s.game = "Tetris"
       AND u.age < 15
       AND s.score > 6000;
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
scores = LOAD './data/scores.tsv' USING PigStorage()
        AS (user:chararray, game:chararray, score:int);
fu = FILTER users BY age < 15;
fs = FILTER scores BY game == 'Tetris' AND score > 6000;
j = JOIN fu BY user, fs by user;
out = FOREACH j GENERATE fs::score, fu::name, fu::age, fu::country;
DUMP out;
```



In order to join multiple datasources you need just to add their tap
and by mentioning the same field name on multiple sources
Cascalog will automatically infer the join key.

### Cascalog
``` clojure
(run<-
 (<-    [?score ?name ?age ?country]
        (USERS  ?name ?user ?age ?country ?active)
        (SCORES ?user ?game ?score)
        (= ?game "Tetris")
        (< ?age 15)
        (> ?score 6000)))
```



If we want to find the who scored the highest points
at the Tetris game we will need to:

### SQL
``` sql
SELECT s.score, u.name, u.age, u.country
  FROM USERS u, SCORES s
 WHERE u.user = s.user
   AND s.game = 'Tetris'
   AND s.score = ( SELECT max(score) FROM SCORES WHERE game = 'Tetris' );
```

### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
scores = LOAD './data/scores.tsv' USING PigStorage()
        AS (user:chararray, game:chararray, score:int);
fs = FILTER scores BY game == 'Tetris';
gfs = GROUP fs ALL;
maxscore = FOREACH gfs GENERATE MAX(fs.score);
j = JOIN users BY user, fs by user;
j2 = JOIN j BY score, maxscore BY $0;
out = FOREACH j2 GENERATE j::fs::score, j::users::name, j::users::age, j::users::country;
DUMP out;
```

### Cascalog
``` clojure
(defn max-game-score [game]
  (<- [?mscore]
      (SCORES _ ?game ?score)
      (= game ?game)
      (c/max ?score :> ?mscore)))

(run<-
 (max-game-score "Tetris"))

(run<-
 (<- [?score ?name ?age ?country]
     (USERS ?name ?user ?age ?country _)
     (SCORES ?user ?game ?score)
     (= ?game "Tetris")
     ((max-game-score "Tetris") ?score)))
```

As we seen from the previous example is very easy to define sub query and reuse them.
In this example I want to find the top 3 scorer per game.
This type of queries is very common for the analytics folks (top-n by group)

### SQL
``` sql
   SELECT s.game, s.score, u.name, u.age, u.country
     FROM SCORES as s
LEFT JOIN SCORES as s2
       ON s.game = s2.game
      AND s.score <= s2.score
     JOIN USERS as u
       ON s.user = u.user
 GROUP BY s.game, s.user
   HAVING count(*) <=3;
```
**NOTE: this O(n^2) very bad!!!**


### Pig
``` ruby
users = LOAD './data/users.tsv' USING PigStorage()
        AS (name:chararray, user:chararray, age:int,
            country:chararray, active:boolean);
scores = LOAD './data/scores.tsv' USING PigStorage()
        AS (user:chararray, game:chararray, score:int);
j = JOIN users BY user, scores by user;
g = GROUP j BY game;
t = FOREACH g {
   s = ORDER j by score DESC;
   l = LIMIT s 3;
   GENERATE FLATTEN(l);
}
out = FOREACH t GENERATE game, score, name, age, country;
DUMP out;
```

### Cascalog
``` clojure
(run<-
 (<- [?game ?score1 ?name1 ?age1 ?country1]
     (SCORES ?user ?game ?score)
     (USERS ?name ?user ?age ?country _)
     (:sort ?score)
     (:reverse true)
     ((c/limit 3) :< ?name ?score ?age ?country :> ?name1 ?score1 ?age1 ?country1)))
```

## Conclusion Has we seen in the previous exmaples Cascalog is very
compact and intuitive. Compared to Pig and SQL is slightly more
succint. However in more complex examples is were we can really
appreciate its simplicity. Again, Cascalog has plenty of other
features which I will try to cover in future posts. The best way to
learn it is to try it, and if you find difficulties you can always
post a message to the
[Cascalog user group](https://groups.google.com/forum/#!forum/cascalog-user).


---

For this article I've used:

  - Cascalog 2.1.0 with Clojure 1.5.1
  - Apache Pig 0.12.1
  - MySql 5.5.37


List of updates:

  - 2014/06/06 Fixed mis-labelled code block (thanks Shashy)
