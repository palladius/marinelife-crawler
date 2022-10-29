#!/usr/bin/env ruby

=begin
  Ispirato da http://ruby.bastardsbook.com/chapters/web-crawling/
  Ora devo solo scaricare alcuni pesci e poi girare intorno.
  Potrei cominciare da https://en.wikipedia.org/wiki/Actinopterygii

  Grandi letture:
  * https://www.rubyguides.com/2012/01/parsing-html-in-ruby/ su come usare Nokogiri, figata.
  *

  Esempi su come usare nokogiri:

  ""

  create_table "fish", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "can_school"
    t.string "latin_name"
    t.text "habitat"
    t.string "wiki"
    t.string "image"
    t.string "emoji"
    t.string "commasep_synonyms"
    t.string "taxo"
  end

  ## BUGS:
  1. https://en.wikipedia.org//wiki/Annelid non e' parsato bene

Scientific classificatione
Kingdom:	Animalia
Subkingdom:	Eumetazoa
Clade:	ParaHoxozoa
Clade:	Bilateria
Clade:	Nephrozoa
(unranked):	Protostomia
(unranked):	Spiralia
Superphylum:	Lophotrochozoa
Phylum:	Annelida
  -
=end

#require 'rubygems'
require "nokogiri"
require "open-uri"
require "lolcat"
require "yaml"
require "pp"
require "pry" # for debuggging
require "colorize"
require_relative "lib/lib_fish"
#require_relative './wiki_fish'

BASE_WIKIPEDIA_URL = "https://en.wikipedia.org"
NOBEL_LIST_URL = "#{BASE_WIKIPEDIA_URL}/wiki/List_of_Nobel_laureates"
$DEBUG = false
Version = "1.3"
MAX_IMPORTS = ENV.fetch("MAX_IMPORTS", "5").to_i
VERBOSE = ENV.fetch("VERBOSE", "FALSE").to_s.downcase == "true"

class String
  def trim
    self.gsub(/^\s+/, "").gsub(/\s+$/, "")
  end
end

FISH_URLS = [
  "https://en.wikipedia.org/wiki/Valentin%27s_sharpnose_puffer",
  "https://en.wikipedia.org/wiki/Actinopterygii",
  "https://en.wikipedia.org/wiki/Pagurus_bernhardus",
  "https://en.wikipedia.org/wiki/Arothron_stellatus",
  "https://en.wikipedia.org/wiki/Caesio_cuning",
  "https://en.wikipedia.org/wiki/Chromodoris", # splendido esempio con sia foto che sublinks
  "https://en.wikipedia.org/wiki/Sea_cucumber",
  "https://en.wikipedia.org/wiki/Blacktip_shark",
  "https://en.wikipedia.org/wiki/Ocean_sunfish" # mai visto, e' enorme!
]

BaseOfflinePages = [
  "parser/https:__en.wikipedia.org_wiki_Valentin%27s_sharpnose_puffer.html",
  "en.wikipedia.org/wiki/Clade",
  "en.wikipedia.org/wiki/Sea_Cucumber"
  #'wiki/Doriprismatica atromarginata - Wikipedia.html',
]

def online?
  #false
  true
end

# et voila!
def list_of_animal_files
  #  `grep -r Animalia en.wikipedia.org/ | cut -f 1 -d: |sort|uniq`.split("\n")
  `egrep -l '/wiki/Chordate.*Chordata' en.wikipedia.org/wiki/A* 2>/dev/null`.split(
    "\n"
  )
end

# copiato da https://stackoverflow.com/questions/46579397/using-rubys-nokogiri-to-scrape-specific-part-of-wikipedia
def smart_morgan_freeman(actor = "Morgan_Freeman")
  html =
    Nokogiri.HTML(
      URI.open("https://en.wikipedia.org/wiki/" + actor.gsub(" ", "_"))
    )

  output = File.new("tmp/#{actor}.txt", "w+")
  output.write(html.to_s)

  person = html.at_css("#firstHeading").text # gets the name
  bday = html.at_css(".bday").text # birthday
  birthplace = html.at_css(".birthplace").text # birthday
  picture_info = html.at_css(".infobox-image").text # TD with infobox
  picture_url = "https:" + html.at_css(".infobox-image").at_css("img")["src"] # "//upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Morgan_Freeman_Deauville_2018.jpg/220px-Morgan_Freeman_Deauville_2018.jpg"
  filmo_list = html.at_css(".div-col") # the div that wraps all the Filmography
  parsed_film = [] # list to add those Films

  puts "== smart_morgan_freeman(#{actor}) == "
  puts " + person: #{person.colorize(:blue)}"
  puts " + bday: #{bday}"
  puts " + birthplace: #{birthplace}"
  puts " + picture_info: #{picture_info} "
  puts " + picture_url:  #{picture_url.colorize(:light_blue)} "

  begin
    filmo_list.at_css("i").each { |l| puts l }
  rescue StandardError
    nil
  end
end

def download_image(url)
  full_url = "#{BASE_WIKIPEDIA_URL}/#{url}"
  file_name = url.split("/").last
  #puts("TODO #{full_url}")
  `wget '#{full_url}' -O 'parser/images/#{file_name}' `
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

# can be remote or local
def fish_page_get_info(path, opts = {})
  opts_debug_links = opts.fetch :debug_links, false
  opts_debug_images = opts.fetch :images_links, false
  opts_download_images = opts.fetch :download_images, true
  opts_limit_entries = opts.fetch :limit_entries, 5

  #path_type = path.match(/^http/) ? 'webpage' : 'local_file'
  h = {
    common_desc: "slurped from wikipedia",
    carlessian_hash_version: "0.2",
    fish: {
    },
    autofish: {
    } # automatically dump to YAML without asking with alreayd proper stuff :)
  }
  # online vs offline: https://nokogiri.org/tutorials/parsing_an_html_xml_document.html#from-a-string
  # magic_parsed_page = path_type == 'webpage' ?
  #   Nokogiri::HTML(URI.open(path)) :
  #   File.open(path) { |f| Nokogiri::HTML(f) } rescue nil
  magic_parsed_page = nokogiri_parse_offline_or_online(path)
  if magic_parsed_page.nil?
    h[:error] = "File opening seemed to fail. Empty Nokogiri doc."
    return h
  end
  # case 1: online
  #online_page = Nokogiri::HTML(URI.open(path))

  # case 2: file (offline)
  #offline_parsed_data = File.open(path){ |f| Nokogiri::HTML(f) }
  #  parsed_data = Nokogiri::HTML.parse(page)

  # h[:noko_file_title] = offline_parsed_data.title
  # h[:noko_online_title] = online_page.title
  h[:noko_title] = magic_parsed_page.title.to_s
  #h[:noko_name] = magic_parsed_page.name.to_s # inutile, sempre 'Document'

  # SELECTOR copiato con Chrome Inspector:
  # #mw-content-text > div.mw-parser-output > table.infobox.biota > tbody > tr:nth-child(6) > td:nth-child(1)
  #  h[:looks_like_an_animal] = online_page.to_s.match?('<a href="/wiki/Animal" title="Animal">Animalia</a>')
  h[:looks_like_an_animal] = magic_parsed_page
    .to_s
    .match?('<a href="/wiki/Animal" title="Animal">Animalia</a>')
    .to_s == "true"

  # cerco di slurtpare il titolo
  title_selector = "#firstHeading > span"
  #  h[:prova_title] = online_page.css(title_selector).to_s
  h[:prova_title] = magic_parsed_page.css(title_selector).to_s if $DEBUG

  if ($DEBUG)
    h[:a_links] = magic_parsed_page.xpath("//a").first(opts_limit_entries)
    # copiato da https://www.rubyguides.com/2012/01/parsing-html-in-ruby/
    if opts_debug_links
      h[:a_links].each { |tag| puts "[LINK_FIGO] #{tag[:href]}\t#{tag.text}" }
    end
    h[:images] = magic_parsed_page.xpath("//img").first(opts_limit_entries)
    h[:images_urls] = h[:images].map { |t| t[:src] }

    h[:images_urls].each do |img_path|
      puts "[IMG_FIGA] #{img_path}" if opts_debug_images
      download_image(img_path) if opts_download_images and online?
    end

    # now CSS
    h[:headers] = magic_parsed_page.css("h1").first(opts_limit_entries)
    h[:paragraphs] = magic_parsed_page.css("p").first(opts_limit_entries)
  end # /if debug

  if h[:looks_like_an_animal]
    # lets find some ANIMAL only stuff
    puts magic_parsed_page.css
    fish_name = magic_parsed_page.at_css("#firstHeading").text # gets the name
    h[:fish][:name] = fish_name
    #h[:fish][:autofish][:name] = fish_name
    h[:autofish]["name"] = fish_name
    #h[:autofish][:emoji] = 'TODO(autofish)'

    # tutti i <p> prima del primo <h2> ed esclusi i vuoti.
    simple_description_css_selector =
      "#mw-content-text > div.mw-parser-output > p:nth-child(4)"
    # e' piu' complesso di cosi, la Descrizione continee N <P> digkli di DIV li sopra e prima di "div id=toc"

    # preoviamo
    # BEGIN parse proper description
    wiki_page_skeleton =
      magic_parsed_page.css("#mw-content-text > div.mw-parser-output > *")
    #puts(wiki_page_skeleton)
    proper_description = "" # 'TODO(ricc): verifica che vadi beno, per ora qui ho aggiunto anche il paragraph number.. togli quando va bene\n\n'
    #proper_description_with_troubleshooting_info = ''
    latin_name = nil
    puts "🔟 wiki_page_skeleton.count = #{wiki_page_skeleton.count}"
    wiki_page_skeleton.each_with_index do |heterogeneous_elem, ix| # can be div, p, table, h2, ..
      puts "#DEB# ix=#{ix} -> name='#{heterogeneous_elem.name}' # lets try to simplify with noko"
      istoc_div = heterogeneous_elem.to_s.match(/<div id="toc"/) # we need to stop here!
      is_a_div = heterogeneous_elem.to_s.match(/<div /)
      #is_a_h2 = heterogeneous_elem.to_s.match(/<h2>/)
      is_a_h2 = heterogeneous_elem.name == "h2"
      is_a_p = heterogeneous_elem.to_s.match(/<p/)
      is_a_empty_p = heterogeneous_elem.to_s.match(/<p class="mw-empty-elt"/)
      is_a_table = heterogeneous_elem.to_s.match(/<table /)
      # inutile solo per abbellire il codice:
      #possible_p = heterogeneous_elem.css('p')
      #puts "\n [possible_p[#{ix}]] ", possible_p.class # .text
      next if is_a_div or is_a_table or is_a_empty_p # do next
      break if (istoc_div or is_a_h2) # finish the game. TOC or H2 indicates end of high description.

      # dpvrebbe essere unb <P> :)
      if is_a_p
        #proper_description << "((ix=#{ix})) #{heterogeneous_elem.text}\n"
        proper_description << "#{heterogeneous_elem.text}\n"
      end
      #puts "\n [MAIN[#{ix}]] ", heterogeneous_elem # .text
      h[:autofish]["description"] = proper_description

      possible_latin_name = heterogeneous_elem.css("i b").text
      #puts "possible_latin_name: '#{possible_latin_name}'"
      latin_name = possible_latin_name if possible_latin_name != ""

      #latin_name
      #puts "DIV" if heterogeneous_elem.is_a?('div')
      #puts "DIV" if heterogeneous_elem.is_a?('p')
    end
    # END parse proper description
    h[:fish][:proper_description] = proper_description
    h[:fish][:latin_name] = latin_name
    h[:autofish]["latin_name"] = latin_name

    h[:fish][:simple_description] = begin
      magic_parsed_page.at_css(simple_description_css_selector).text
    rescue StandardError
      ""
    end
    # 'TODO find right css :)'
    h[:fish][:wiki] = "https://" + magic_parsed_page.url
    h[:autofish]["wiki"] = "https://" + magic_parsed_page.url

    h[:fish][:taxo] = parse_fish_taxonomy(magic_parsed_page)
    h[:autofish][:taxo_removeme_debug] = h[:fish][:taxo] # 'https://' + magic_parsed_page.url
    h[:autofish]["emoji"] = h[:fish][:taxo][:emoji]
    h[:autofish]["taxo"] = h[:fish][:taxo][:carlessian_taxonomy]
    h[:autofish]["image"] = h[:fish][:taxo][:image]
    #FUNGE! h[:fish][:deemingly_fish_links] =  magic_parsed_page.xpath("//a").select{|x| x.to_s.match /fish/i }
  end

  #rows = online_page.css('div.mw-content-ltr table.wikitable tr')
  #h[:prova_taxo_rows] = rows
  print page if $DEBUG

  # returning the hash
  return h
end

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

=begin

SAMPLE:


<tr>
<th colspan="2" style="min-width:15em; text-align: center; background-color: rgb(235,235,210)"><a href="/wiki/Taxonomy_(biology)" title="Taxonomy (biology)">Scientific classification</a> <span class="plainlinks" style="font-size:smaller; float:right; padding-right:0.4em; margin-left:-3em;"><a href="/wiki/Template:Taxonomy/Holothuroidea" title="e"><img alt="e" src="//upload.wikimedia.org/wikipedia/commons/7/74/Red_Pencil_Icon.png" decoding="async" width="16" height="16" data-file-width="16" data-file-height="16" /></a></span>
</th></tr>
<tr>
<td>Kingdom:
</td>
<td><a href="/wiki/Animal" title="Animal">Animalia</a>
</td></tr>
<tr>
<td>Phylum:
</td>
<td><a href="/wiki/Echinoderm" title="Echinoderm">Echinodermata</a>
</td></tr>
<tr>
<td>Subphylum:
</td>
<td><a href="/wiki/Echinozoa" title="Echinozoa">Echinozoa</a>
</td></tr>
<tr>
<td>Class:
</td>
<td><a class="mw-selflink selflink">Holothuroidea</a><br /><small><a href="/wiki/Henri_Marie_Ducrotay_de_Blainville" title="Henri Marie Ducrotay de Blainville">Blainville</a>, 1834</small>
</td></tr>

=> expected result:

  :Kingdom => 'Animalia' ,
  :Class => 'Holothuroidea',
  ...

=end
def parse_fish_taxonomy(document)
  taxo_hash = {}
  # full XPATH:
  # Doriplasmatica Kingdom CSS: #mw-content-text > div.mw-parser-output > table > tbody > tr:nth-child(3) > td:nth-child(1)
  #kingdom_css = '#mw-content-text > div.mw-parser-output > table > tbody > tr:nth-child(3) > td:nth-child(1)'
  # /html/body/div[3]/div[3]/div[5]/div[1]/table[1]/tbody/tr[5]/td[1]
  #taxo_hash[:Kingdom_cheating] = 'Animalia (removeme)'
  #taxo_hash[:Kingdom_css] = document.css(kingdom_css)

  #taxo_hash[:wiki_sposta_di_sopra] = document.url # (kingdom_css)
  taxo_hash[:emoji] = "🐠" #  (kingdom_css)
  # Phylum
  #phylum_css = '#mw-content-text > div.mw-parser-output > table > tbody > tr:nth-child(4)'
  #taxo_hash[:phylum_css] = document.css(phylum_css).text.gsub("\n",'')

  #sobenme_css_6th_tr = '#mw-content-text > div.mw-parser-output > table.infobox.biota > tbody > tr:nth-child(6)'

  #taxo to be iterated
  whole_taxo_css =
    "#mw-content-text > div.mw-parser-output > table > tbody > tr"
  #taxo_hash[:whole_taxo_todo_iterate]
  taxo_rows = document.css(whole_taxo_css)

  #puts taxo_rows[:emoji]
  # <tr>
  # <td>Kingdom:
  # </td>
  # </td></tr>
  # <td><a href="/wiki/Animal" title="Animal">Animalia</a>
  # dovrebbe iterare su tanti TR con due TDs :)
  arr_carlessian_taxonomy = []
  arr_carlessian_taxonomy_with_index = []
  taxo_rows.each_with_index do |row, ix|
    cleaned_up_text = row.text.gsub("\n", " ").chomp
    #hrefs = row.css("td a").map{ |a|
    #puts "  - [ROW] '#{cleaned_up_text}' [#{row}]\n\n"
    #puts "  - [ROW] '#{cleaned_up_text}'\n\n"

    # dimentichiamo l'Order apposta per un attimo..
    if taxo_match =
         cleaned_up_text.match(
           /^[ ]+(Kingdom|Subkingdom|Phylum|Class|Family|Clade|Order|Index|Genus|Species|Superphylum):( )+([\w ]+)$/
         )
      my_lowercase_class = taxo_match[1].downcase
      my_instance = taxo_match[3].trim
      taxo_hash[my_lowercase_class] = my_instance
      arr_carlessian_taxonomy << my_instance
      arr_carlessian_taxonomy_with_index << "(#{ix}) #{my_instance}"

      if my_instance.match? /\n/
        raise "FATAL some CRLFs in name! #{my_instance}"
      end
      #taxo_hash[my_class.to_s + '2'] = cleaned_up_text.split(':')[1].trim # chomp
      #puts "FUNGE! Vedi: #{row}"
      #puts "  - GOTCHA[#{ix}] '#{cleaned_up_text}' " # [#{row}]\n\n" # if $DEBUG
    elsif taxo_match_ripescaggio =
          cleaned_up_text.match(
            /^[ ]+(Kingdom|Phylum|Class|Order|Family|Genus|Species):( )+([\w ]+)$/
          )
      puts "🟨 Potentially a taxo name you havent looked at: ix=#{ix} '#{taxo_match_ripescaggio[1]}'"
    end
  end
  taxo_hash[:carlessian_taxonomy] = arr_carlessian_taxonomy.join(" > ")
  taxo_hash[
    :carlessian_taxonomy_with_index
  ] = arr_carlessian_taxonomy_with_index.join(" > ")

  if taxo_hash["kingdom"].to_s == ""
    puts "Empty Kingdom -> returning error"
    taxo_hash["error"] = "Empty Kingdom, should be ANIMAL"
    return taxo_hash
  end
  #raise "Not an animal! (kingdom=#{taxo_hash['kingdom']})" unless taxo_hash['kingdom'] == 'Animalia'
  #raise "Not a chordatum! (Phylum=#{taxo_hash['Phylum']})" unless taxo_hash['Phylum'] == 'Chordata'

  taxo_image_css_selector =
    "#mw-content-text > div.mw-parser-output > table > tbody > tr:nth-child(2) > td > a > img"
  noko_imagez = document.css(taxo_image_css_selector)
  noko_imagez.each_with_index do |image, ix|
    image_url =
      begin
        "https:" + image["src"]
      rescue StandardError
        nil
      end # .css('.src')
    # https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Doriprismatica_atromarginata.JPG/440px-Doriprismatica_atromarginata.JPG
    #puts "  [#{ix}] 📸 IMAGE1: #{image_url}"
    taxo_hash[:image] = image_url

    #puts "  [#{ix}] 📸 IMAGE2src: #{image_url['src'] rescue $! }"
    # xpath("//img").first
  end
  #taxo_hash[:images] = noko_imagez
  #taxo_hash[:images2] = noko_imagez.to_s

  taxo_hash
end

def parse_fish_riccardo(page_url, opts = {})
  opts_verbose = opts.fetch :verbose, false

  puts("[DEB] parse_fish_riccardo: ")
  unique_file_name = "./wiki/" + page_url.split("/").last.to_s + ".wiki.txt"
  # tanto e gratis ..
  `wget '#{page_url}' -O '#{unique_file_name}'`

  page = Nokogiri.HTML(URI.open(page_url))
  sanitized_page_url = page_url.gsub("/", "_")
  File.write("parser/#{sanitized_page_url}.html", page)

  hash_info = fish_page_get_info(sanitized_page_url)
  puts hash_info.inspect if opts_verbose
  rows = page.css("div.mw-content-ltr table.wikitable tr")
end

# ad mentulam canis..
def prova_uri()
  URI.open("http://www.ruby-lang.org/") { |f| f.each_line { |line| p line } }
end

def dump_fish_info_into_yaml_file(
  fish_hash,
  filename,
  is_it_first_today = false
)
  # initialize if needed
  puts "dumping fish info into this file '#{filename}'. if first time (#{is_it_first_today}) im gonna alos delete it first"
  if is_it_first_today
    File.write(
      filename,
      "# initialized on #{Time.now} from #{$0} v#{Version}\n\n"
    )
  end
  if fish_hash.fetch :error, false
    # File.open(filename, 'a') { |f|
    #   f.write("# Skipping #{fish_hash}")
    # }
    puts "Skipping #{fish_hash} ..."
    return false
  end

  #end
  indented_object = {
    "WikiCrawler v#{Version} - #{fish_hash[:autofish]["name"]}" =>
      fish_hash[:autofish].except(:taxo_removeme_debug)
    # fish_obj_to_dump_to_file
  }
  useful_but_commented_debug_info =
    fish_hash[:autofish][:taxo_removeme_debug].to_yaml.gsub(/^/, "#DEBI# ")
  File.open(filename, "a") do |f|
    f.write("#" * 80 + "\n")
    f.write("# Error (should be empty): '#{fish_hash[:error]}'\n")
    f.write("# LooksLikeNAnimal: #{fish_hash[:looks_like_an_animal]}\n")
    f.write(
      "# useful_but_commented_debug_info:\n#{useful_but_commented_debug_info}\n"
    )
    #f.write "# todo yaml for #{fish_obj_to_dump_to_file.inspect}\n"
    #f.write(pp  fish_obj_to_dump_to_file.inspect)
    #pp fish_obj_to_dump_to_file.inspect
    f.write(indented_object.to_yaml)
    puts indented_object.to_yaml
    f.write("#" * 80 + "\n")
  end
  return true
end

def main()
  # main
  include LibFish

  puts "#{$0} v#{Version} START on #{Time.now}"

  puts "ENV[MAX_IMPORTS]=#{MAX_IMPORTS}"
  puts "ENV[VERBOSE]=#{VERBOSE}"

  # if online?
  #   smart_morgan_freeman('Morgan Freeman') if online?
  #   smart_morgan_freeman('Tom Cruise') if online?
  #   smart_morgan_freeman('Mike Myers') if online?
  # end
  #puts "1. iterate_through_files_in_directory:"
  iterate_through_files_in_directory(
    "samples/",
    "out/fish-sample.yaml",
    verbose: VERBOSE,
    max_imports: MAX_IMPORTS
  )
  iterate_through_files_in_directory(
    "en.wikipedia.org/wiki/",
    "out/fish-from-wiki-crawl.yaml",
    verbose: VERBOSE,
    max_imports: MAX_IMPORTS
  )
  #puts fishnames_from_yaml("fish-sample.yaml")
  #puts fishnames_from_yaml("fish-from-wiki-crawl.yaml")

  # puts "2. ok. Now with fish..."
  # # this doesnt require onlinity :)
  # offline_pages = BaseOfflinePages +  list_of_animal_files()
  # offline_pages.each_with_index do |page, ix|
  #   puts "👀 Inspecting: '#{page.colorize(:white)}' 👀"
  #   ret = fish_page_get_info(page, :limit_entries => 2) # if you :dont_mind
  #   puts ret.inspect if $DEBUG
  #   puts "🐠 HABEMUS PESCEM: '#{ret[:noko_title]}'" if ret[:looks_like_an_animal] # == 'true'
  #   dump_fish_info_into_yaml_file(ret, 'wikipedia-slurp.yaml', ix==0) if ret[:looks_like_an_animal] == true

  #   break if ix > (MAX_IMPORTS > 0 ? MAX_IMPORTS : 1000000) # never if 0 or less
  # end
  # #prova_uri() if online?
  # # parse_noble_prizes_DO_NOT_TOUCH(NOBEL_LIST_URL)
  # FISH_URLS.each do |fish_url|
  #   x = parse_fish_riccardo(fish_url) if online?
  # end

  # END / finally
  unless online?
    puts "☢️⚠️⛔️ ACTHUNG! Note that ONLINE has been disabled. Lot of juicy stuff wont work, probably cos Riccardo is on a plane"
  end
end

main
