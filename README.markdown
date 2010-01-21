WhereBeUs
=========

WhereBeUs is the easiest way to find out where your friends are *right now*.

* Sign in with _facebook_ or _twitter_ and instantly see your friends on the map.
* Easily send messages to your friends.
* Completely free and open source.

WhereBeUs was written by [Dave Peck](http://davepeck.org/) and [Brian Dorsey](http://briandorsey.info/). (c) 2009-2010 All Rights Reserved.

FAQ
---

Q: Why?

A: For fun, and for no other reason. This was an exercise in getting something very simple, but polished, out the door quickly.


Q: No, seriously. Why?

A: We took a look at several similar applications and decided that none of them quite worked the way we wanted them to. Some were very maximalist: not an option for us since this was a several-week exercise. Some required users to create new accounts and establish new friendship relations, which frankly we don't think is a good way to go forward. By leveraging Twitter and Facebook we think we've lowered the barrier to entry for people to use an app like this. But time will tell.


Q: But haven't you heard of Latitude/etc?

A: Yep. Latitude is simple too, and we like that, but the problem is you have to create entirely new accounts and social connections. Not for us! Also, Latitude doesn't have a nice iPhone front-end (yet.)


Q: How much work did it take?

A: More than we expected. We originally called this our "two weeks, evenings only" app. It turned out to be about "six weeks, evenings only." Not so bad. Part of the reason it took so long is because we completely changed the way the app worked about three weeks in. Check the repo history for details. :-)


Q: Can I contribute?

A: Yes, please do!

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

[Dave Peck](http://davepeck.org/) & [Brian Dorsey](http://briandorsey.info/)
