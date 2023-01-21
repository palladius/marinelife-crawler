
# def parse_noble_prizes_DO_NOT_TOUCH(page_url)
#   page = Nokogiri::HTML(URI.open(page_url))
#   sanitized_page_name = page_url.gsub('/','_')
#   sanitized_page_url = "parser/#{sanitized_page_name}.html"
#   File.write(sanitized_page_url, page)

#   # da qui si rompe..
#   rows = page.css('div.mw-content-ltr table.wikitable tr')

#   rows[1..-2].each do |row|

#     hrefs = row.css("td a").map{ |a|
#       a['href'] if a['href'] =~ /^\/wiki\//
#     }.compact.uniq

#     hrefs.each do |href|
#       remote_url = BASE_WIKIPEDIA_URL + href
#       puts remote_url
#     end # done: hrefs.each

#   end # done: rows.each
# end

  # if online?
  #   smart_morgan_freeman('Morgan Freeman') if online?
  #   smart_morgan_freeman('Tom Cruise') if online?
  #   smart_morgan_freeman('Mike Myers') if online?
  # end

  # ad mentulam canis..
def prova_uri()
  URI.open("http://www.ruby-lang.org/") { |f| f.each_line { |line| p line } }
end
