#require "htmlentities"

module LibFish
  # carlessian module to parse wikipedia fish...
  #  TaxonomyCompleExtractionRegex = /^[ ]+(Kingdom|Subkingdom|Phylum|Superclass|Class|Family|Clade|Order|Index|Genus|Species|Superphylum):( )+([\w ]+)$/
  TaxonomyRegex =
    /(Kingdom|Subkingdom|Phylum|Superclass|Class|Family|Clade|Order|Index|Genus|Species|Superphylum)/
  WikiCrawlerVersion = "0.9"

  # given a wiki URL / content, tells you if its a fish
  def smells_like_fish?(wiki_content)
    wiki_content.match?(/Chordata/) rescue false
    # rescue "Problems with wiki content '''#{wiki_content}''': #{$!}"
  end

  def nokogiri_parse_offline_or_online(path)
    path_type = path.match(/^http/) ? "webpage" : "local_file"
    magic_parsed_page =
      (
        if path_type == "webpage"
          Nokogiri.HTML(URI.open(path))
        else
          File.open(path) { |f| Nokogiri.HTML(f) }
        end
      ) # rescue nil
  end

  def iterate_through_files_in_directory(path, target_yaml, output_yaml_list, opts = {})
    opts_max_imports = opts.fetch :max_imports, 1_000_000
    opts_verbose = opts.fetch :verbose, false
    opts_debug = opts.fetch :debug, false
    #puts("iterate_through_files_in_directory opts: #{opts}")

    files_to_iterate_upon = Dir.glob("#{path}/**/*").first(opts_max_imports)
    puts "🤟 iterate_through_files_in_directory(path='#{path.colorize(:cyan)}', write_to='#{target_yaml.colorize(:cyan)}', max=#{opts_max_imports})"

    if opts_verbose
      puts "== Iterate upon #{files_to_iterate_upon.count} files (max #{opts_max_imports}) ==".colorize(
             :white
           )
      puts files_to_iterate_upon
    end

    n_fishes = 0
    n_nay = 0
    files_to_iterate_upon.each do |filename|
      if File.directory?(filename)
        puts "[DEB] skipping (path=#{file})" if opts_debug
        next
      end
      file_content = File.read(File.expand_path filename)
      if smells_like_fish?(file_content)
        puts "🐠 We have a FISH: #{filename}" if opts_verbose
        ret = smart_wiki_parse_fish(filename, opts)
        write_fish_info_to_yaml_file(ret, target_yaml, n_fishes == 0) # i cant use the each with index, in case first wiki file is nOT a fish :)
        n_fishes += 1
      else
        n_nay += 1
      end
    end
    puts "📊 Total fishes: #{n_fishes} (vs #{n_nay} non fishes)"
    if (output_yaml_list)
      puts "📊 YAML file contains these:"
      fishes = fishnames_from_yaml(target_yaml)
      fishes.each do |fishname|
        puts "🍣 #{fishname}"
      end
    end

  end

  # dumps a hash into a yaml. Since you can write MANY hashes into a yaml, also has a boolean which says if you need to
  # initialize it or not.
  def write_fish_info_to_yaml_file(
    fish_hash,
    filename,
    initialize_too = false,
    opts = {}
  )
  opts_verbose = opts.fetch :verbose, false
  opts_debug = opts.fetch :debug, true

    # initialize if needed
    if opts_verbose
      puts "# Dumping cleanedup_fish_hash info into this file '#{filename}'. If first time (#{initialize_too}) im gonna also delete it first"
    end
    # remove debug info unless debug set up.
    #cleanedup_fish_hash = opts_debug ? fish_hash : fish_hash.except("taxo_removeme_debug")
    cleanedup_fish_hash = fish_hash.except("taxo_removeme_debug")
    pp(cleanedup_fish_hash) if opts_verbose

    if initialize_too # creates empty file.
      File.write(
        filename,
        "# initialized on #{Time.now} from #{$0} v#{Version}\n\n"
      )
    end
    if fish_hash.fetch(:error, false)
      # File.open(filename, 'a') { |f|
      #   f.write("# Skipping #{fish_hash}")
      # }
      puts "Skipping #{fish_hash} ..."
      return false
    end

    indented_object = {
      "WikiCrawler v#{WikiCrawlerVersion} - #{fish_hash["name"]}" =>
        cleanedup_fish_hash
    }
    useful_but_commented_debug_info =
      fish_hash[:taxo_removeme_debug].to_yaml.gsub(/^/, "#DEBI# ")

    File.open(filename, "a") do |f|
      f.write("#" * 80 + "\n")
      #f.write("# Error (should be empty): '#{fish_hash[:error]}'\n")
      #f.write("# LooksLikeNAnimal: #{fish_hash[:looks_like_an_animal]}\n")
      f.write(
        "# useful_but_commented_debug_info:\n#{useful_but_commented_debug_info}\n"
      )
      #f.write "# todo yaml for #{fish_obj_to_dump_to_file.inspect}\n"
      #f.write(pp  fish_obj_to_dump_to_file.inspect)
      #pp fish_obj_to_dump_to_file.inspect
      f.write(indented_object.to_yaml)
      puts indented_object.to_yaml if opts_verbose
      pp(fish_hash["taxo_removeme_debug"]) if opts_debug
      f.write("#" * 80 + "\n")
    end


    return true
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

 A PROBLEMATIC ONE:

   "<tr><td>Class:</td><td><a class=\"mw-selflink selflink\">Asteroidea</a><br><small><a href=\"/wiki/Henri_Marie_Ducrotay_de_Blainville\" title=\"Henri Marie Ducrotay de Blainville\">Blainville</a>, 1830</small></td></tr>"],
 "taxo_byindex_7"=>["Class", "AsteroideaBlainville, 1830"],

=end

  def fishnames_from_yaml(yaml_file)
    ret = []

    #hash =
    YAML.load_stream(File.read(yaml_file)).each do |document|
      #puts document.keys
      sub_hash = document[document.keys.first]
      ret << sub_hash['name_with_short_taxo']
#      puts sub_hash['taxo']
      # hash.each do |fish, fish_info|
      #   ret << fish_info['name']
      # end
    end
    ret
  end

  def smart_wiki_parse_fish(fish_url_name, opts = {})
    opts_debug = opts.fetch :debug, false
    opts_verbose = opts.fetch :verbose, false

    fish_info = {}
    fish_info["taxo"] = {}
    fish_info["fish_url_name"] = fish_url_name
    fish_info["taxo_removeme_debug"] = {}
    fish_info["taxo_removeme_debug"]["arrkeys"] = []
    fish_info["taxo_removeme_debug"]["arrvals"] = []
    html = nokogiri_parse_offline_or_online(fish_url_name)
    #html = Nokogiri::HTML(URI.open("https://en.wikipedia.org/wiki/" + fish_url_name.gsub(' ','_')))

    fish_info["wiki"] = html.at_css("head > link[rel=canonical]")["href"]
    # useless, i have NAME which is better...
    fish_info["taxo_removeme_debug"][
      "title_name"
    ] = URI.decode_www_form_component(
      # HTMLEntities.new.decode(
      fish_info["wiki"].gsub("https://en.wikipedia.org/wiki/", "")
    ).gsub("_", " ")

    # not only taxo.. :)
    fish_info["name"] = html.at_css("#firstHeading").text # gets the name
    fish_info["picture_url"] = "https:" +
      html.css(".image").at_css("img")["src"] rescue nil
    fish_info["binomial_name"] = begin
      html.at_css(".binomial").text
    rescue StandardError
      "-"
    end
    # 4th element of <P> is debateable..
    fish_info["simple_description_p4"] = begin
      html
        .at_css("#mw-content-text > div.mw-parser-output > p:nth-child(4)")
        .text
        .gsub(/\n/, "")
    rescue StandardError
      "no P4 description"
    end

    # list of taxonomix TRs..
    whole_taxo_css =
      "#mw-content-text > div.mw-parser-output > table > tbody > tr"
    taxo_rows = html.css(whole_taxo_css)

    #taxo_infobox = html.css( whole_taxo_css).css('tbody') # ("table.infobox > tbody")
    #puts taxo_infobox # .css('tbody') # ['tbody']
    taxo_rows.each_with_index do |taxorow, ix|
      next unless taxorow.to_s.match? TaxonomyRegex
      #puts "#DEB #{taxorow.to_s.gsub(/\n/, "").colorize(:white)}"
      #puts " + #{ix} taxorow: #{taxorow.text}" # if taxorow.to_s.match? TaxonomyRegex
      taxo_key = taxorow.css("td:first").text.trim().gsub(/:$/, "") # remove trailing colon
      taxo_value =
        begin
          taxorow.css("td:nth-child(2) > a").text.trim()
        rescue StandardError
          $!
        end

        # check its ok
        if taxo_value =~ /\d\d\d\d/
          # i think ive fixed it by adding " > a "
          puts "Soemthing smells fishy lets fix it.. try BEFORE BR or firs A value"
          puts "[TAXOVAL] #{taxo_value}" if opts_debug
          puts "[TAXO_OBJ] #{taxorow.css("td:nth-child(2)").to_s.colorize( :yellow)}" if opts_debug
          # selector: #mw-content-text > div.mw-parser-output > table.infobox.biota > tbody > tr:nth-child(8) > td:nth-child(2) > a
          puts "[TAXO_OBJ] #{taxorow.css("td:nth-child(2) > a").to_s.colorize( :green)}" if opts_debug
        end
        # should fix the bug of this example: I want  "Actinopterygii", not  "ActinopterygiiKlein, 1885"
      #  + taxo_byindex_6: [6, "Class", "ActinopterygiiKlein, 1885", "<tr><td>Class:</td><td><a class=\"mw-selflink selflink\">Actinopterygii</a><br><small><a href=\"/w/index.php?title=Adolf_von_Kl
      #   ein&amp;action=edit&amp;redlink=1\" class=\"new\" title=\"Adolf von Klein (page does not exist)\">Klein</a>, 1885</small></td></tr>"]
      linked_taxo_value = taxorow.css("td:nth-child(2) > a").text.trim()
      fish_info["taxo_removeme_debug"]["taxo_byindex_verbose_#{ix}"] = [
        ix,
        taxo_key,
        linked_taxo_value,
        taxorow.to_s.gsub(/\n/, "")
      ] # if opts_verbose
      fish_info["taxo_removeme_debug"]["arrkeys"] << taxo_key
      fish_info["taxo_removeme_debug"]["arrvals"] << linked_taxo_value

      #fish_info["taxo_byindex_#{ix}"] = [taxo_key, linked_taxo_value]
      fish_info["taxo_removeme_debug"]["taxo_byindex_#{ix}"] = [
        taxo_key,
        linked_taxo_value
      ]
      fish_info["taxo"][taxo_key] = linked_taxo_value # taxo_value
      if taxo_key == "Species" and taxo_value.match?(/\./)
        if opts_debug
          puts "😉 I gotta feeling that i can infer the abbreviation for #{taxo_value.colorize(:yellow)}.."
        end
        if opts_debug
          puts "Taking it from Species-1 which i assume to be Genus: '#{fish_info["Genus"]}'"
        end
        # if genus, happy days. if not, i need to find the previous _7 -> _6
        substitute_dot_with_previous =
          fish_info["Genus"].nil? ? "something_else_then" : fish_info["Genus"]
        new_taxo_value =
          "Fixing WIP.. " + taxo_value.gsub(".", substitute_dot_with_previous)
        fish_info["taxo_removeme_debug"]["RICCFIXED_#{taxo_key}"] = new_taxo_value
        if opts_debug
          puts "Semi-fixed (still WIP). New value is #{new_taxo_value.colorize(:green)}"
        end
      end

      short_taxo = fish_info["taxo_removeme_debug"]["arrvals"].join(' > ')
      #fish_info["taxo"].keys # .keys.join(', ')
      fish_info["name_with_short_taxo"] = "#{fish_info['name']} (#{short_taxo})"

      # found a bug in Starfish To be fixed
      if taxo_value =~ /, [12][6789]\d\d/ # == "AsteroideaBlainville, 1830"
        raise(
          "2BFIXED_BUG (date inside taxo by mistake, eg for Starfish). Maybe you stop at first TBODY or better parse the TD TR penso che devi fermarti al primo tbody cosi non fa gli altri..."
        )
      end
    end

    # visualize output which is pretty cool
    if opts_verbose
      puts "== smart_wiki_parse_fish(#{fish_url_name.to_s.colorize(:azure)}) == "
      fish_info.each do |k, v|
        puts " + #{k.to_s.white}: #{v.to_s.colorize(:blue)}"
      end
    end

    fish_info
  end
end
