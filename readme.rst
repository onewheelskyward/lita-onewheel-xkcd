lita-onewheel-xkcd
==================

.. image:: https://travis-ci.org/onewheelskyward/lita-onewheel-xkcd.png?branch=master :target: https://travis-ci.org/onewheelskyward/lita-onewheel-xkcd
.. image:: https://coveralls.io/repos/onewheelskyward/lita-onewheel-xkcd/badge.svg?branch=master&service=github :target: https://coveralls.io/github/onewheelskyward/lita-onewheel-xkcd?branch=master

A Lita_ handler to display XKCD comics in your chat handler of choice.  


Installation
------------
Add lita-onewheel-xkcd to your Lita instance's Gemfile:
::
  gem "lita-onewheel-xkcd"


Configuration
-------------
Unless you're running the defaults, you'll want to specify your database connection values like so:

..
Lita.configure do |config|
  config.handlers.onewheel_xkcd.db_host = 'localhost'
  config.handlers.onewheel_xkcd.db_name = 'lita_xkcd'
  config.handlers.onewheel_xkcd.db_user = 'root'
  config.handlers.onewheel_xkcd.db_pass = ''
  config.handlers.onewheel_xkcd.db_port = 5432
end

Usage
-----
xkcd: Returns a random XKCD comic.
xkcd 411: Returns xkcd.com/411's comic.
xkcd ballmer: returns my favorite Steve Ballmer comic.
xkcd next: returns the next comic by index.
xkcd prev: returns the previous comic by index.


Engineering Notes
-----------------

Current comic(including top number): http://xkcd.com/info.0.json 

Comic by number: http://xkcd.com/1/info.0.json

How to map # to date?  - it's in the meta

Parser script, import into postgres?  Best way to handle json

Keyword tokenizer, it's substring searching at the moment.

.. _Lita: http://lita.io/
