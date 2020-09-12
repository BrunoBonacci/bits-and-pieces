---
layout: post
title: Yet, another post about Ops, DevOps, NoOps!
date:  2012-03-24 21:00:00
categories: [methodologies, devops]
tags: [methodologies, devops]
---


In the past few days I’ve seen strong exchange of opinions about the
different Ops flavours. In particular Adrian
([@adrianco](https://twitter.com/adrianco)) from Netflix, in a series
of twitter posts, defined as "NoOps" a certain number of practices
adopted by Netflix development teams to push in production changes by
themselves without depending on Ops teams. The twitter posts, and most
probably, the presence of the "No" prefix, have been largely
mis-interpreted by Ops communities. Adrian with
[this post](http://perfcap.blogspot.co.uk/2012/03/ops-devops-and-noops-at-netflix.html),
tried to clarify what the term NoOps means in NetFlix.

My background is Dev, so I entirely understand Adrian’s point of
view. I also spent few years in QA trying to make systems more
scalable, reliable, resilient, etc., and somehow I do understand some
of the Ops criticisms to generally irresponsible Dev teams. Dev is
generally measured in delivery throughput, so the more they change the
better it is. Ops is traditionally measured by stability, so the less
they change the better it is. How this can possibly go wrong!!
Finally, some big companies apply the "segregation of duties"
(madness) that surely doesn’t help the communication between Dev and
Ops.

In the past few years, we saw the emergent movement of DevOps whose
main intent is to break this wall between the two disciplines and get
them to talk. Now NoOps, as it has been perceived by the communities
(not as described by Adrian), looks like Dev won’t need Ops any more.

To get a better understanding of Ops, DevOps and NoOps I’ll try to explain them with parallel in everyday life.

#### The Ops case

If instead of building software and services we were building a large
shopping centre, Dev would be represented by the engineering and
construction team. At project termination, to “run” the shopping
centre with all facilities, services and shops, a complete different
team takes over. People from this team don’t have engineering or
construction skills, but they know how to run the service. They have
business knowledge, the know the clientèle, they understand the user’s
needs, they know how to run a shop and maintain relationships with
vendors and suppliers. Of course they know the sopping centre
structure very well. So far things sounds very normal.

#### The DevOps case

In the above example, after the buildings are ready to host shops and
clients, we take another team of engineers and builders (different
from the one that built the centre), and ask them to run the
business. Since they have a very good understanding of the structural
problem and capacity concepts of the individual shopping areas they
make sure that escalators, lift, and facilities run accordingly. They
have knowledge of supply chain management, but not necessarily they
understand the business potentials, and they will do things such as
limiting the number of people that access the shopping area to avoid
overcrowding (limiting revenues as well).

### The NoOps case

In this case the engineering team and the builders that built the
centre decide to run the shopping centre by themselves. So they try to
understand the business by accessing data such as daily revenues and
customer visits of individual shops. They try to improve general
throughput and improve the structure where needed, but they might miss
completely some business opportunities because their core skills are
elsewhere.

Another analogy can be taken from the design and construction of a
Formula 1 car and the Grand Prix race. Again, engineering teams (DEV)
design and build a perfect car. NoOps says: "I’ve built it, I’ll drive
it!!" (good luck). For DevOps case, we will select a good mechanic and
ask him to run the race for us. Something like: "...you know how
does't work, no? this is the steering wheel, this is to accelerate,
press this start. But remember, never press the red button.!!!" and
they never say why. Of course inevitably the button is pressed and the
ejection mechanism activated. In the Ops case, we would carefully
select a good driver, explain him how the car works, train him on the
road with the car, collecting precious feedback from him, and finally
ask him to run the Gran Prix.

On those analogies it appears clearly that the "pure" Ops strategy is
the best. Building a service and running it requires very different
skills. Sometime there are few overlapping but both areas need to be
specialized.

So why this doesn’t work with software development? I personally think
that has to do with the fact that most of the operational teams tend
to avoid as much as possible changes and releases. In the real life
analogy, the Ops team of a shopping centre would never stop
engineering teams from fixing a broken lift or improving a old area,
because they know that, although there will be some inconvenience, the
engineering works will improve the overall business; maybe attracting
new customers, maybe expanding business opportunities or simply
improving the service. Similarly the Formula 1 pilot would be very
happy to get the latest aerodynamics improvements on the car, or the
new super techno tires, because they’ll improve his chances to win the
race.

So, where is the catch? The catch is that the common target should
prevail over the resistance to the change. In the real life analogies
the driver would have full trust of his engineers, and
vice-versa. This doesn’t happen in IT mostly because Dev team they
don’t share responsibilities of running the services, and usually, Ops
doesn’t benefit from Dev changes that in many cases are poorly tested,
and they cause problems.

Of course this doesn’t apply to all realities. Where the communication
and collaboration between those teams is encouraged, and there is
mutual trust and respect things works better. That’s why DevOps is
actually more effective than traditional Ops. Netflix pushes things an
extra mile. If engineers (Dev and Ops) are directly responsible to run
the service and they respond directly to their system failures, this
make them aware of certain issues and necessities that usually
operation team have. Things like resilience, monitoring, admin tools
are too often tagged as “Nice to have” and never properly implemented.

So NoOps, as pointed out
[in this post](https://gist.github.com/jallspaw/2140086), is NOT the
absence of an operation team, but just very good Ops practices ran by
Dev. In particularly I would say that instead of talking of NoOps we
are actually talking about SelfOps. In fact at Netflix the DevOps
teams have built tools to automate and enable Dev teams to Self-serve
their operations needs (finally the right kind of
automation). Therefore, in my opinion, NoOps (or SelfOps as I call it)
is just the best Ops you can have! By building automation tools they
have removed the historical dependency from Dev. As consequence they
increased the delivery throughput as the business requires and
minimized the risk by sharing responsibilities.

#### In conclusion

It’s all down to three key elements: __communication, mutual trust and most important shared responsibility__.

So if you are a Dev, take direct responsibility of the software that
you build and try to run it together with Ops. If you are an Ops, ask
your Dev peer to sit together with you and have a look to logs,
metrics, and other system parameters to get a better understanding of
the system, and then write some tool to make sure that Dev doesn’t
need you to push changes to production.

Tomorrow flying to Malaysia for a couple of weeks of relaxing holidays.  :-)
