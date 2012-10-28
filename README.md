# Puppet module for Riak

This module allows you to manage Riak with puppet.

Riak is a Dynamo-inspired key/value store that scales predictably and easily.
Riak combines a decentralized key/value store, a flexible map/reduce engine,
and a friendly HTTP/JSON query interface to provide a database ideally suited
for Web applications. And, without any object-relational mappers and other
heavy middleware, applications built on Riak can be both simpler and more
powerful.  For complete documentation and source code, see the Riak home page
at [Basho][1].

## Getting Started

**Have a look at the [Wiki][2].**

### Tested on:

 * Ubuntu 12.04 LTS (Precise) 64-bit - works, 
 * Debian 6.0 (Squeeze) 64-bit
 * CentOs 6.3 64-bit

## Development Environment

You can simply clone this module like normal to your puppet-modules-folder.
It'll work. Done.

If you want to check that it works, then install `vagrant`, `rake` and
`VirtualBox`, then run `rake vagrant:up`.

----

**For more details info, see [Testing with Vagrant][3] on the wiki.**

### References

 * http://www.slideshare.net/PuppetLabs/modern-module-development-ken-barber-2012-edinburgh-puppet-camp
 * http://www.slideshare.net/Alvagante/puppet-modules-an-holistic-approach
 * http://puppetlabs.com/blog/puppet-module-bounty-logstash-riak-and-graphite/?utm_campaign=blog&utm_medium=socnet&utm_source=twitter&utm_content=modbounty1
 * http://puppetlabs.com/blog/the-next-generation-of-puppet-module-testing/

### Outstanding External Issues

Working on this module has been really nice, but unfortunately it's
noticeable that not most people actually unit-test their puppet modules.

I think puppet is an awesome project, and I would love for the tooling
around creating powerful modules to improve. Here are some of my experienced
bumps in the road.

 * https://github.com/rodjek/rspec-puppet/issues/44

   This issue affects the tests, making them impossible to run cleanly
   together at the moment. The only way around it, is to launch rspec
   first for `classes`, then for `functions`.

 * https://github.com/rubyist/guard-rake/issues/12

   This issue is solved by Joerg, but he hasn't submitted a pull request,
   so I've cloned his repository and am using my own clone of that, until
   the issue is resolved (about 4 lines of code) in master. Affects
   running of rake when the task raises errors.

 * https://github.com/amfranz/rspec-hiera-puppet/issues/3

   This issue affects a single test that exposed the issue; overriding
   puppet variables with rspec variables. The test is currently marked as
   pending.

#### Example42

From your excellent presentations I could find online, and your samples
at your github. Thanks Alessandro.

[1]: http://basho.com/
[2]: https://github.com/basho/puppet-riak/wiki
[3]: https://github.com/basho/puppet-riak/wiki/Testing-with-Vagrant
