
SHELL := /bin/bash

# downloads under en.wikipedia.org/wiki/
WGET_COMMAND = wget  -r -e robots=off --no-parent --continue --wait=2 --limit-rate=100K

SIMPLE_WGET_COMMAND_THERE = cd  en.wikipedia.org/wiki && wget

install:
	bundle install

fish-crawl-wikipedia:
	MAX_IMPORTS=15 ./crawl-wikipedia.rb

fish-crawl-buggysamples:
	FISH_FOLDER=buggy-samples/ VERBOSE=false DEBUG=true MAX_IMPORTS=2 ./crawl-wikipedia.rb

fish-crawl-super-duper:
	OUTPUT_YAML=out/fish-from-wiki-crawl.yaml MAX_IMPORTS=1215  FISH_FOLDER=en.wikipedia.org/wiki/ ./crawl-wikipedia.rb

install:
	gem install nokogiri open-uri colorize

wget-crawl-holothuria:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Holothuria'
wget-crawl-starfish:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Starfish'

wget-crawl-triggerfish:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Triggerfish'
wget-crawl-triggerfishCategory:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Category:Balistidae'
wget-crawl-shark:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Shark'
wget-crawl-chromodoris:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Chromodoris'


single-wgets:
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Whale
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Dolphin
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Manta_Ray

