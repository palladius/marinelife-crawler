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

  #default_value = 'Category:Fish_taxonomy'
  default_value = 'Tiger_shark'

  # https://en.wikipedia.org/wiki/Category:Fish_taxonomy
  # This seems the best

  #die('give me some nice Fish pages to start from, like: ') if ARGV == 0

  fish_to_be_crawled = "https://en.wikipedia.org/wiki/#{ ARGV.size > 0 ? ARGV[0] : default_value }"

  max_stack_size = ENV.fetch( 'MAX_STACK_SIZE', 9999).to_i

  crawl_with_condition(fish_to_be_crawled, true,
    max_stack_size: max_stack_size,
    overwrite_files: false,
  )
end

main()
