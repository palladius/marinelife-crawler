
SHELL := /bin/bash

# downloads under en.wikipedia.org/wiki/
WGET_COMMAND = wget  -r -e robots=off --no-parent --continue --wait=2 --limit-rate=100K --no-clobber

SIMPLE_WGET_COMMAND_THERE = cd  en.wikipedia.org/wiki && wget

install:
	bundle install
	if_mac brew install wget
	gem install nokogiri open-uri colorize

fish-crawl-wikipedia:
	MAX_IMPORTS=15 ./crawl-wikipedia.rb
fish-crawl-wikipedia-dabon:
	MAX_IMPORTS=100000 ./crawl-wikipedia.rb

fish-crawl-buggysamples:
	FISH_FOLDER=buggy-samples/ VERBOSE=false DEBUG=true MAX_IMPORTS=2 ./crawl-wikipedia.rb

fish-crawl-super-duper:
	OUTPUT_YAML=out/fish-from-wiki-crawl.yaml MAX_IMPORTS=1215  FISH_FOLDER=en.wikipedia.org/wiki/ ./crawl-wikipedia.rb


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
wget-crawl-bluedragon: # Glaucus_atlanticus
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Glaucus_atlanticus'


single-wgets:
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Whale
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Dolphin
	$(SIMPLE_WGET_COMMAND_THERE) https://en.wikipedia.org/wiki/Manta_Ray

test:
#	FISH_FOLDER=buggy-samples/ VERBOSE=true DEBUG=true MAX_IMPORTS=1 RUN_TESTS=true ./crawl-wikipedia.rb
	ruby wiki_fish_test.rb
