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

=begin
  Example taxonomy parsing:
   + taxo: {"Kingdom"=>"Animalia", "Phylum"=>"Chordata", "Class"=>"Actinopterygii", "Order"=>"Tetraodontiformes", "Family"=>"Balistidae", "Genus"=>"Balistoides", "Species"=>"B. conspicillum", "RICCFIXED_Species"=>"Fixing WIP.. Bsomet
hing_else_then conspicillum"}
 + wiki: https://en.wikipedia.org/wiki/Clown_triggerfish
 + taxo_byindex_4: [4, "Kingdom", "Animalia", "<tr><td>Kingdom:</td><td><a href=\"/wiki/Animal\" title=\"Animal\">Animalia</a></td></tr>"]
 + taxo_byindex_5: [5, "Phylum", "Chordata", "<tr><td>Phylum:</td><td><a href=\"/wiki/Chordate\" title=\"Chordate\">Chordata</a></td></tr>"]
 + taxo_byindex_6: [6, "Class", "Actinopterygii", "<tr><td>Class:</td><td><a href=\"/wiki/Actinopterygii\" title=\"Actinopterygii\">Actinopterygii</a></td></tr>"]
 + taxo_byindex_7: [7, "Order", "Tetraodontiformes", "<tr><td>Order:</td><td><a href=\"/wiki/Tetraodontiformes\" title=\"Tetraodontiformes\">Tetraodontiformes</a></td></tr>"]
 + taxo_byindex_8: [8, "Family", "Balistidae", "<tr><td>Family:</td><td><a href=\"/wiki/Triggerfish\" title=\"Triggerfish\">Balistidae</a></td></tr>"]
 + taxo_byindex_9: [9, "Genus", "Balistoides", "<tr><td>Genus:</td><td><a href=\"/wiki/Balistoides\" title=\"Balistoides\"><i>Balistoides</i></a></td></tr>"]
 + taxo_byindex_10: [10, "Species", "B. conspicillum", "<tr><td>Species:</td><td><div style=\"display:inline\" class=\"species\"><i><b>B. conspicillum</b></i></div></td></tr>"]

=end

  def smart_wiki_parse_fish(fish_url_name, opts={})
    opts_debug = opts.fetch :debug, true
    opts_verbose = opts.fetch :verbose, true

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
      fish_info["taxo_byindex_verbose_#{ix}"] = [ix, taxo_key, linked_taxo_value, taxorow.to_s.gsub(/\n/, "") ] if opts_verbose
      fish_info["taxo_byindex_#{ix}"] = [taxo_key, linked_taxo_value]
      fish_info['taxo'][taxo_key] = linked_taxo_value # taxo_value
      if taxo_key == 'Species' and taxo_value.match?(/\./)
        puts "😉 I gotta feeling that i can infer the abbreviation for #{taxo_value.colorize(:yellow)}.."
        puts "Taking it from Species-1 which i assume to be Genus: '#{fish_info['Genus']}'"
        # if genus, happy days. if not, i need to find the previous _7 -> _6
        substitute_dot_with_previous = fish_info['Genus'].nil? ? 'something_else_then' : fish_info['Genus']
        new_taxo_value = "Fixing WIP.. " + taxo_value.gsub( '.', substitute_dot_with_previous )
        fish_info['taxo']["RICCFIXED_#{taxo_key}"] = new_taxo_value
        puts "Semi-fixed (still WIP). New value is #{new_taxo_value.colorize(:green)}"
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
