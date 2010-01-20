WhereBeUs
=========

WhereBeUs is the easiest way to find out where your friends are *right now*.

* Sign in with _facebook_ or _twitter_ and instantly see your friends on the map.
* Easily send messages to your friends.
* Completely free and open source.

WhereBeUs was written by [Dave Peck](http://davepeck.org/) and [Brian Dorsey](http://briandorsey.info/). (c) 2009-2010 All Rights Reserved.

Why?
----

We wrote this for fun, and because we felt that just about every other similar app out there wasn't very good. We think ours is the simplest possible app of this sort.

The Code
--------

WhereBeUs is released under the BSD license. There are a few third-party libraries in the code base; those are licensed separately.

As of January 19, 2010 we have:

* A very minimal user-facing website that runs on App Engine
* A highly scalable back-end API (same App Engine app)
* An iPhone front-end
    
There's a lot of work to do on all fronts. For starters, we'd love to see:

* A web exposure that lets users log in and see their friends in their browser (desktop)
* Android front-end
* WebOS front-end
* A bit more thinking about how messages travel between friends -- it is bare bones on the iPhone right now.
    
Building & Contributing
-----------------------

We hope to build a large community around this project. The code from the `master` branch should always build without problem.

Currently you must have App Engine SDK 1.3.0+ and the XCode tools in order to work on this project.

The iPhone application will only partially work if "built out of the box." It will work fine with Twitter, but for Facebook you'll need to create a new Facebook application and set the secret key appropriately.

Feel free to add to our issues list or just drop us an email.

Cheers,
[Dave Peck](http://davepeck.org/)
[Brian Dorsey](http://briandorsey.info/)
