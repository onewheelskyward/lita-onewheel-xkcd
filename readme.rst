lita-onewheel-xkcd
==================

.. image:: https://travis-ci.org/onewheelskyward/lita-onewheel-xkcd.png?branch=master :target: https://travis-ci.org/onewheelskyward/lita-onewheel-xkcd
.. image:: https://coveralls.io/repos/onewheelskyward/lita-onewheel-xkcd/badge.svg?branch=master&service=github :target: https://coveralls.io/github/onewheelskyward/lita-onewheel-xkcd?branch=master

A Lita_ handler to display XKCD comics in your chat handler of choice.  


Installation
------------
Get a postgres instance running, give this guy access to write to the two tables in scripts/schema.rb.
Add lita-onewheel-xkcd to your Lita instance's Gemfile:
::
  gem "lita-onewheel-xkcd"


Configuration
-------------
Unless you're running the defaults, you'll want to specify your database connection values like so:
::
  Lita.configure do |config|
    config.handlers.onewheel_xkcd.db_host = 'localhost'
    config.handlers.onewheel_xkcd.db_name = 'lita_xkcd'
    config.handlers.onewheel_xkcd.db_user = 'root'
    config.handlers.onewheel_xkcd.db_pass = ''
    config.handlers.onewheel_xkcd.db_port = 5432
    config.handlers.onewheel-xkcd.alt_delay = 15   # Optional; 9 is the default.
  end

Usage
-----
All commands return the comic, and then display the alt text alt_delay seconds later.

:xkcd: Returns a random XKCD comic.
:xkcd 411: Returns xkcd.com/411's comic.
:xkcd ballmer: returns my favorite Steve Ballmer comic.
:xkcd next: returns the next comic by index.
:xkcd prev: returns the previous comic by index.
:xkcdupdate: Updates the database with the latest comics.  Manually, for now.

Engineering Notes
-----------------

Current comic(including top number): http://xkcd.com/info.0.json 

Comic by number: http://xkcd.com/1/info.0.json

How to map # to date?  - it's in the meta

Keyword tokenizer, it's substring searching at the moment.

Add postgres setup and details on how to update the database with new comics.

.. _Lita: http://lita.io/
