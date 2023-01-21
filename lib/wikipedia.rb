
require 'colorize'
require "mechanize"
require_relative './fishness.rb'
require 'set'


include Fishness

module Wikipedia

  # Click button on wikipedia
  # https://stackoverflow.com/questions/10032494/mechanize-how-to-get-current-url
  def wikipedia_search_button(search_string)
    ret_hash = {}

    a = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

    a.get("http://en.wikipedia.org/") do |page|
      search_result = page.form_with(id: "searchform") { |frm| frm.search = search_string }.submit
      ret_hash[:uri] = search_result.uri
      ret_hash[:title] = search_result.title
#      puts "search_result.uri: #{search_result.uri}"  # .parser.css("h1").text
#      puts "search_result.parser: #{search_result.parser}"  # .parser.css("h1").text
      ret_hash[:first_h1] = search_result.parser.css("h1").text
      return ret_hash
    end

    return nil
  #=> United States
  end

  def crawled_url_looks_like_a_fish(stringified_uri)
    return false if stringified_uri =~ /:/
    return false if stringified_uri =~ /Main_Page/

    return false if stringified_uri =~ /The_Philobiblon|World_Book_|Wireless_Markup_Language/
#🕷️ Examining: '/wiki/The_Philobiblon'
#🕷️ Examining: '/wiki/Outline_of_books'
#🕷️ Examining: '/wiki/World_Book_Capital'
#🕷️ Examining: '/wiki/World_Book_Day'

    return false if stringified_uri.match?(/^\/w\/index.php/)
    return false if stringified_uri.match?(/^\#/)
    return false if stringified_uri.match?(/.*\/Wikipedia:/)
    return false if stringified_uri.match?('/wiki/Category:')
    return false if stringified_uri.match?(/.*\/(Category|Special|Wikipedia|User_talk|Portal|Help|Template|Module):.*/)
    true
  end


  # from: https://github.com/sparklemotion/mechanize/blob/main/EXAMPLES.rdoc
  def google_links(search_string)
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    a.get('http://google.com/') do |page|
      search_result = page.form_with(:id => 'gbqf') do |search|
        search.q = 'Hello world'
      end.submit

      search_result.links.each do |link|
        puts link.text
      end
    end
  end

  # Takes an initial page and a `bool lambda(page_content)` crawls all pages
  # my_lambda.call
  # inspired by https://github.com/sparklemotion/mechanize/blob/main/examples/spider.rb
  def crawl_with_condition(initial_page_url, boolean_method, opts={})
    opts_verbose = opts.fetch :verbose, false

    fish_set = Set['Cielcio']                        #=> #<Set: {1, 2}>

    puts "WELCOME TO CRAWLER OF PAGE: #{initial_page_url.to_s.colorize :green}"

    agent = Mechanize.new
    #agent.max_history = nil # unlimited history
    agent.max_history = 3 # unlimited history
    stack = agent.get(initial_page_url).links

    while l = stack.pop
      next unless l.uri
      host = l.uri.host
      next unless host.nil? or host == agent.history.first.uri.host
      #return if @seen = @agent.visited?(link)
      next if agent.visited? l.href

      #puts "🕷️ Examining: '#{l.uri}'"


      # EXMAINING PURE TITLE
      if crawled_url_looks_like_a_fish(l.uri.to_s) # or stringified_uri.match?(/^\#/)
        puts "🕷️ Examining: '#{l.uri}'" if opts_verbose
      else
        #puts "❌ Dropping: '#{l.uri}'" if opts_verbose
        next
      end

      begin
        page = l.click
        if is_fish_by_wikipedia_content?(page.content)
          puts "🍱 Habemus piscem: #{page.uri} . Stack size: #{stack.size}. fish_setSize: #{fish_set.size}"
          # if already has it, lets do next so we skip recursion which is eating me... :/
          if fish_set.member?(page.uri.to_s)
            puts "🐚 Existing fish - bresaking the recustion with NEXT" if opts_verbose
            next
          else
            fish_set.add(page.uri.to_s)
          end
        else
          puts "😭 No, woman no fish... " if opts_verbose
          next
        end
        # CHECK CONTENT
        #puts page.content
        #puts page.title
        next unless Mechanize::Page === page
        stack.push(*page.links)
      rescue Mechanize::ResponseCodeError
      end
    end

    puts "🕷️🕷️🕷️ The crawl has ended, go in peace. 🕷️🕷️🕷️"
  end

end
