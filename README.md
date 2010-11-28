Bitcache: Distributed Content-Addressable Storage
=================================================

Bitcache is a distributed content-addressable storage (CAS) system. It
provides repository storage for bitstreams (colloquially known as blobs) of
any length, each uniquely identified and addressed by a digital fingerprint
derived through a secure cryptographic hash algorithm.

* <http://github.com/bendiken/bitcache>

Documentation
-------------

<http://bitcache.rubyforge.org/>

* {Bitcache::Adapter}
* {Bitcache::Encoder}
* {Bitcache::Repository}
* {Bitcache::Stream}

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [Addressable](http://rubygems.org/gems/addressable) (>= 2.2.1)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the Bitcache gem, do:

    % [sudo] gem install bitcache

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/bitcache.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/bitcache/tarball/master

Resources
---------

* <http://bitcache.rubyforge.org/>
* <http://github.com/bendiken/bitcache>
* <http://rubygems.org/gems/bitcache>
* <http://rubyforge.org/projects/bitcache/>
* <http://raa.ruby-lang.org/project/bitcache/>
* <http://www.ohloh.net/p/bitcache>

See also
--------

* [Bitcache for Drupal](http://drupal.org/project/bitcache)
* [Bitcache/Java](http://github.com/bendiken/bitcache-java)

Author
------

[Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

Contributors
------------

Refer to the accompanying `CREDITS` file.

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Backports]: http://rubygems.org/gems/backports
