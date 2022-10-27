
WGET_COMMAND = wget  -r -e robots=off --no-parent --continue --wait=2 --limit-rate=100K


install:
	bundle install

ruby-crawl:
	./crawl-wikipedia.rb

install:
	gem install nokogiri open-uri colorize

wget-crawl-holothuria:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Holothuria'
wget-crawl-starfish:
	$(WGET_COMMAND) 'https://en.wikipedia.org/wiki/Starfish'
