---
layout: post
title: Vert.x Goodness - Simple Telnet Server
date:   2012-06-30 21:00:00
categories: [development]
tags: [Actor-model, concurrency, Groovy, lock-free-algorithm, Vert.x]
---

One of the coding test that I often assign to developers when I do
interview is to implement a simple Telnet server in Java. Not a
full-fledged Telnet server compliant to the
[RFC-854](http://tools.ietf.org/html/rfc854), but just a non-secure,
small brother with just few commands implemented.

In general I do ask the following things:

- The Telnet server must be able to accept multiple concurrent connections
- The server must be able to maintain the connection state (working directory) across multiple commands
- A base directory must be specified, this will be the root directory "/" for the connecting users and they shouldn't be allowed to reach any parent directory (like chroot)
- The Telnet server must support at least the following commands:
  - `cd [<path>]` - to change the current working directory
  - `pwd` - to display the current directory
  - `mkdir <path>` - to create a new directory
  - `ls [<path>]` - to list the content of the current/specified directory
  - `quit` - to close the connection
- Of course, you can't spawn external processes to run those commands in their native OS implementation, otherwise would be cheating.

This simple task hide several details and coding challenges such as: session management, threads management, resource usage/closing, security vulnerabilities, scalability problems etc.

A couple of weeks ago I came across [Vert.x](http://vertx.io/) as the
website says: _"Effortless asynchronous application development for
the modern web and enterprise"_. The main page shows a code snippet of
a web-server able to serve static pages/files in about 4-5 lines of
code. I personally like when I see that a software package is
presenting on the home page a code snippet that shows how to use their
software. The reason being that if the software is easy enough to be
explained in few lines and appear in the home page, maybe I won't
waste so much time on learn it. I've been designing and developing
software for more than 20 years, and nowadays big part of my focus
goes into simplicity and elegance, and Vert.x meet both.

Let's explore some of the Vert.x key characteristics:

* **Vert.x is Polyglot** - you can implement your application in
  *Java, Groovy, JavaScript and Ruby*. _And you can mix-and-match them
  in the same application_. For example you can develop your database
  connection in Java, your XML processing in Groovy (Java APIs are way
  too boring compared to Groovy's one), and add some others script in
  JavaScript or Ruby. New languages support are under development such
  as Python and Scala.

* **Asynchronous** - It supports non-blocking IO (NIO) as default
  implementation for more scalability and performance.
* **Exceptional Threading model** - The design is brilliant! It offers
  a simplified threading model based on the Actors model. In this
  implementation every "Verticle" instance (any Vert.x implementation)
  is guaranteed to run in the same thread at all time. Multiple
  instances are **isolated** in different class loaders and every
  instance will always run in the same thread. This makes very easy to
  implement multi-threaded system with lock-free solutions. Most of
  the time you won't need to think about multiple concurrent access,
  locks and semaphores.
* **Vert.x is embeddable** - It is packaged and shipped in a container
  solution ready to host web application, but if you want to embed it
  in your application it is very easy.
* **Extensible** - At the core of the design there is an event bus
  that is responsible for inter-verticle communication. This
  asynchronous bus offer the possibility to write modules in any of
  the supported languages and reuse them in multiple
  applications. Additionally you can put multiple instances in a
  cluster directly supported by the core implementation.
* **Simplicity** - It is so easy to write code with Vert.x that in few
  lines you can get very good scalable solutions.

To try out some of those interesting properties I've tried to
implement the Telnet server using Vert.x and Groovy and here is the
solution explained.

## Things you shouldn't be doing with Vert.x

Vert.x has two type of Verticles that are mapped in two different
thread pools. Normal Verticles that are fully on NIO and they run on
event loop thread pool. By default Vert.x create one event loop thread
per available CPU core. The second one are Verticles that use
traditional blocking I/O and they are called worker verticles; those
verticles run in a thread pool called background thread pool. Now if
in your Verticle you access a database with a driver that doesn't
support NIO, or you print some information to the console, or you
access files directly or indirectly (such as via the log) or any other
I/O that is not fully asynchronous you end up blocking one of the
event loop thread for some blocking I/O reducing effectively the
performances. If you can, use NIO for all above things; if you can't
then run your Verticle as a worker verticle (see
[documentation](http://vertx.io/manual.html#verticle) for more info).

In the following example I'll make use of blocking IO in a Verticle
because I'll print debug messages to the console. Additionally I'll
use the traditional Java File implementation that doesn't support
NIO. Vert.x comes with a very handy NIO Filesystem access
implementation, this could be used to improve the code that you'll
see. So please consider the following code as example not as template
to follow.

## The Session management.

The strategy here is pretty simple. Upon a new connection I assign a
new connectionId (cid) and add it in a unsynchronized local map. I
don't have to worry about others threads accessing this map or any
concurrent modification because by design Vert.x guarantee that this
code will ever be executed from the same thread. The map will contain
session information such as current working directory.

``` groovy
// this is the base directory where all user will be segregated (like: "chroot")
BASE_DIR = new File(System.properties.baseDir ?: "/tmp").canonicalPath;

// This map maintains the session state for every connection.
// for this telnet server the state will be limited to the current directory
_connections = [:];

// Connection id counter
_cids = 0;

// assigning an id to a new connection
def registerConnection() {
    String cid = "${++_cids}"
    _connections[cid] = [curDir: BASE_DIR]
    return cid;
}
```

## The Telnet server.

For socket server will use the NIO and add handlers on new incoming
connections. Those handlers will take care of registering a new
connection, handle incoming requests and handle the connection
close. The code will look like this:

``` groovy
// general configuration
settings = [port: 1234];

// Vert.x server and event-bus
def server = vertx.createNetServer()
def bus = vertx.eventBus

// Connection handler. Here requests are captured, parsed, and executed.
server.connectHandler { sock ->
    // upon a new connection, assigning a new connection id (cid)
    String cid = registerConnection();
    println "[$cid]# got a new connection id: $cid - currently ${_connections.size()} are alive.";

    // welcome the user with a message
    sock.write(welcome())

    // handle the connection close.
    sock.closedHandler {
        _connections.remove(cid);
        println "[$cid]# The connection is now closed"
    }

    // handle incoming requests from a single connection
    // a request, might contains multiple commands, splitting them by line.
    sock.dataHandler { buffer ->
        def lines = new String(buffer.bytes).trim().split("\r\n").collect { it.trim() }
        lines.each {
            println "[$cid]> $it"
            if (it == "") return

            // if a command is found send it to the commands-handler
            bus.send("commands", [command: it, cid: cid]) {
                resp ->
                // once you get a response for a command
                // then send it back to the user
                String outMessage = prepareOutput(resp.body.message)
                if (outMessage != "") {
                    sock.write("$outMessage\r\n") {
                        println "[$cid]< " + outMessage.replaceAll("\n", "\n[$cid]< ")
                    }
                }

                // if the command was "quit", close the connection.
                if (resp.body.status == "ACTION" && resp.body.action == "QUIT")
                    sock.close()
            }
        }
    }
}.listen( settings.port );

println """
---------------------------------------------------------------------
                   Simple Vert.x Telnet Server
---------------------------------------------------------------------
(*) Server started at $BASE_DIR and listening on port: $settings.port
"""
```

## Commands dispatching

Once I get a command, the command is sent to the bus to the commands
handler that will process the request and reply via the bus. In this
case the command handler try to match the request with a list of valid
command patterns, then call the associated function and reply to the
bus with the output of the command itself.

``` groovy
// Regular expression to verify/extract pathnames from commands
PATH_ELEM = "[A-Za-z0-9.-]+"
PATH = "(/?$PATH_ELEM(/$PATH_ELEM)*/?|/)"

// Commands handler
bus.registerHandler("commands") {
    msg ->
    def cmd = msg.body.command
    switch (cmd) {
        case ~$/cd( $PATH)?/$:
            def path = cmd.size() > 3 ? cmd[3..-1] : ""
            msg.reply(cd(path, msg.body.cid));
            break;
        case ~$/ls( $PATH)?/$:
            def path = cmd.size() > 3 ? cmd[3..-1] : ""
            msg.reply(ls(path, msg.body.cid));
            break;
        case ~$/mkdir $PATH/$:
            def path = cmd[6..-1]
            msg.reply(mkdir(path, msg.body.cid));
            break;
        case ~$/quit/$:
            msg.reply([status: "ACTION", action: "QUIT", message: "Goodbye!!!"]);
            break;
        default:
            msg.reply([status: "ERROR", message: "### ERROR: Sorry, this command is unrecognized!"]);
    }
}
```

At this point the command implementation is very easy. The change directory "cd" command will look like this:

``` groovy
////////////////////////////////////////////////////////////////////////// cd
def cd(def path, String cid) {
    path = path == "" ? null : path
    def newPath = virtual2real(path, cid);

    if (!newPath.exists() || !newPath.isDirectory())
        return [status: "ERROR", message: "### ERROR: $path: no such directory!".toString()]

    // changing directory
    _connections[cid].curDir = new File(newPath.canonicalPath);

    return [status: "OK", message: ""];
}



File virtual2real(def path, def cid) {
    def newPath = new File(BASE_DIR);

    if (path != null) {
        if (path.startsWith("/"))
            newPath = new File("$BASE_DIR$path");
        else
            newPath = new File("${_connections[cid].curDir}/$path");
    }

    // security: in case goes above root like: /../../
    if (!newPath.canonicalPath.startsWith(BASE_DIR))
        newPath = new File(BASE_DIR);

    return newPath;
}
```

Remember that users will be limited to see directory only under the
`BASE_DIR` like a sort of chroot command from Linux. When the user
specifys `cd /dir1` in his telnet session, this directory it refers to
`"$BASE_DIR/dir1"` on the server side. In the `virutal2real()`
function I transform a user path into a server real pathname. To avoid
that malicious users do things like `"cat /../../../etc/passwd"` and
bypass my root directory I have to make sure that any path they
specify is still under the `$BASE_DIR` and if not, then I will force
the `$BASE_DIR` as root directory. A similar behaviour is enforced in
your Linux system when you try to enter the following command `"cd
/../.."` and you will still end up to the root directory `"/"`, in
other words the root directory is the parent of itself.

## Conclusion.

We have seen how easy is to safely write multi-thread application in
Vert.x. The threading model that Vert.x implements, takes care of many
aspects of concurrent programming, effectively helping the developer
to avoid using shared state objects and having to synchronize
access. The full implementation of this system with some other
additional implemented commands is available on GitHub at
[https://github.com/BrunoBonacci/vertx-telnet](https://github.com/BrunoBonacci/vertx-telnet). However
this code isn't well designed and implemented, and it is just for
demonstrate the simplicity of writing network servers with Vert.x.

For instance the above code doesn't support authentication, ignores
totally the different encoding between clients and servers, it has a
monolithic implementation (it is only one Groovy script) and, as I've
already mentioned earlier, it does synchronous I/O printing debugging
information out to the server console as well as accessing the file
system with blocking I/O functions.

Nevertheless its simplicity, this sever can handle hundreds of
concurrent users easily. However since every command execution is
going to run in a single thread, you won't be able, with this
implementation, to scale up and use the full capacity of your
multiprocessor machine. Vert.x comes in your help in this allowing you
to spawn multiple instances scaling more efficiently up your server
capacity. Having said that, the above code has a design flaw that you
can easily fix. By running multiple instances of this small server,
Vert.x will start sending requests in round-robin fashion to all
instances. Since every instance is isolated from the other with a
different class loader, the map with the connection state
(_connections) is not going to be shared. Actually you will have one
new instance of this map for every server instance, so incoming
request might ending up in a instance that doesn't hold the connection
state for that particular request. An easy way to fix this in line
with the Actor model is to extract the map and registration process
into a separate Verticle with only one instance and connect the
registration through the event bus. This allow to maintain the session
management handled by a single thread and scale the server up to the
number of available processors. Vert.x offers also another way. There
is the possibility to share some data structures like map and set with
immutable objects. This come handy to implement things like shared
cache etc.

I really enjoyed exploring Vert.x, although it proposes itself as main
competitor for Node.js, I think it has far more capabilities than a
simple web-server. Its good design makes Vert.x as an excellent
alternative for many of the web-server implementations of high-volumes
services. Certainly in the next week weeks I will explore more this
interesting aspect of Vert.x and coming up with new Vert.x goodnesses.

---
Full source code available at: [https://github.com/BrunoBonacci/vertx-telnet](https://github.com/BrunoBonacci/vertx-telnet)
