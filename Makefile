
SHELL := /bin/bash

# downloads under en.wikipedia.org/wiki/
WGET_COMMAND = wget  -r -e robots=off --no-parent --continue --wait=2 --limit-rate=100K

SIMPLE_WGET_COMMAND_THERE = cd  en.wikipedia.org/wiki && wget

install:
	bundle install

ruby-crawl:
	VERBOSE=TRUE MAX_IMPORTS=15 ./crawl-wikipedia.rb

install:
	gem install nokogiri open-uri colorize

wget-crawl-holothuria:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Holothuria'
wget-crawl-starfish:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Starfish'

wget-crawl-triggerfish:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Triggerfish'
wget-crawl-shark:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Shark'
wget-crawl-chromodoris:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Chromodoris'


single-wgets:
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Whale
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Dolphin
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Manta_Ray

