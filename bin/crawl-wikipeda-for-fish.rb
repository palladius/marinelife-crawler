#!/usr/bin/env ruby

puts "PWD: #{`pwd`}"

#require 'lib/wikipedia.rb'
#require '../lib/wikipedia.rb'
require_relative  '../lib/wikipedia.rb'

include Wikipedia
# http://ruby.bastardsbook.com/chapters/web-crawling/#h-2-7


def main()
  #puts wikipedia_search_button('U. S.') #=> United States
  #puts wikipedia_search_button('Dolphin')

  #BROKEN google_links('Riccardo Carlesso')

  default_value = 'Category:Fish_taxonomy'
  # https://en.wikipedia.org/wiki/Category:Fish_taxonomy
  # This seems the best

  fish_to_be_crawled = ARGV.size > 0 ?
    "https://en.wikipedia.org/wiki/#{ ARGV[0] }" :
    "https://en.wikipedia.org/wiki/#{default_value}"

  crawl_with_condition(fish_to_be_crawled, true)
end

main()
