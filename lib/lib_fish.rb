module LibFish
  # carlessian module to parse wikipedia fish...
#  TaxonomyCompleExtractionRegex = /^[ ]+(Kingdom|Subkingdom|Phylum|Superclass|Class|Family|Clade|Order|Index|Genus|Species|Superphylum):( )+([\w ]+)$/
  TaxonomyRegex = /(Kingdom|Subkingdom|Phylum|Superclass|Class|Family|Clade|Order|Index|Genus|Species|Superphylum)/

  # given a wiki URL / content, tells you if its a fish
  def smells_like_fish?(wiki_content)
    wiki_content.match?(/Chordata/)
  end

  def nokogiri_parse_offline_or_online(path)
    path_type = path.match(/^http/) ? 'webpage' : 'local_file'
    magic_parsed_page = path_type == 'webpage' ?
      Nokogiri::HTML(URI.open(path)) :
      File.open(path) { |f| Nokogiri::HTML(f) } # rescue nil
  end

  def iterate_through_files_in_directory(path, opts={})
    puts Dir.glob("#{path}/**/*")

    n_fishes = 0
    n_nay = 0
    puts "[DEB] iterate_through_files_in_directory(path=#{path})"
    Dir.glob("#{path}/**/*").each do |filename|
      if File.directory?( filename)
        #puts "[DEB] skipping (path=#{file})"
        next
      end
      file_content = File.read(File.expand_path filename)
      if smells_like_fish?(file_content)
        puts " FISH #{filename}"
        smart_wiki_parse_fish(filename)
      else
        #puts " nay #{file}"
        n_nay += 1
      end
    end
    puts "Totals fishes: #{n_fishes} (vs #{n_nay} non fishes)"
  end


  def smart_wiki_parse_fish(fish_url_name)
    fish_info={}
    fish_info['taxo'] = {}
    html = nokogiri_parse_offline_or_online(fish_url_name)
    #html = Nokogiri::HTML(URI.open("https://en.wikipedia.org/wiki/" + fish_url_name.gsub(' ','_')))

    fish_info['wiki'] = html.at_css('head > link[rel=canonical]')['href']
    if (false) # rimuovimi troubleshooting taxo..
      fish_info['name'] = html.at_css('#firstHeading').text # gets the name
      fish_info['picture_url'] = 'https:' + html.css('.image').at_css('img')['src']
      fish_info['bonomial_name'] = html.at_css('.binomial').text rescue '-'
      fish_info['simple_description'] = html.at_css('#mw-content-text > div.mw-parser-output > p:nth-child(4)').text.gsub(/\n/, '')
    end
    # list of taxonomix TRs..
    whole_taxo_css = '#mw-content-text > div.mw-parser-output > table > tbody > tr'
    taxo_rows = html.css(whole_taxo_css)

    #taxo_infobox = html.css( whole_taxo_css).css('tbody') # ("table.infobox > tbody")
    #puts taxo_infobox # .css('tbody') # ['tbody']
    taxo_rows.each_with_index do |taxorow, ix|
      next unless taxorow.to_s.match? TaxonomyRegex
      #puts "#DEB #{taxorow.to_s.gsub(/\n/, "").colorize(:white)}"
      #puts " + #{ix} taxorow: #{taxorow.text}" # if taxorow.to_s.match? TaxonomyRegex
      taxo_key = taxorow.css('td:first').text.trim().gsub(/:$/,'') # remove trailing colon
      taxo_value = taxorow.css('td:nth-child(2)').text.trim() rescue $!
      # should fix the bug of this example: I want  "Actinopterygii", not  "ActinopterygiiKlein, 1885"
      #  + taxo_byindex_6: [6, "Class", "ActinopterygiiKlein, 1885", "<tr><td>Class:</td><td><a class=\"mw-selflink selflink\">Actinopterygii</a><br><small><a href=\"/w/index.php?title=Adolf_von_Kl
      #   ein&amp;action=edit&amp;redlink=1\" class=\"new\" title=\"Adolf von Klein (page does not exist)\">Klein</a>, 1885</small></td></tr>"]
      linked_taxo_value = taxorow.css('td:nth-child(2)').text.trim()
      fish_info["taxo_byindex_#{ix}"] = [ix, taxo_key, linked_taxo_value, taxorow.to_s.gsub(/\n/, "") ]
      fish_info['taxo'][taxo_key] = linked_taxo_value # taxo_value
      if taxo_key == 'Species' and taxo_value.match?(/\./)
        puts "I gotta feeling that i can infer the abbreviation for #{taxo_value}.."
        puts "Taking it from Species-1 which i assume to be Genus: '#{fish_info['Genus']}'"
        fish_info['taxo']["RICCFIXED_#{taxo_key}"] = "Fixing.. #{taxo_value}"
      end

      raise('BUG for Starfish penso che devi fermarti al primo tbody cosi non fa gli altri...') if taxo_value == 'AsteroideaBlainville'
    end



    puts "== smart_wiki_parse_fish(#{fish_url_name.to_s.colorize(:azure)}) == "
    fish_info.each do |k,v|
      puts " + #{k.to_s.white}: #{v.to_s.colorize(:blue)}"
    end

    fish_info
  end



end
