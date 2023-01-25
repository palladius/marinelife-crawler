# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


#!/usr/bin/env ruby

require 'colorize'
require_relative '../../lib/lib_fish.rb'
require 'yaml'

#from LibFish include fish_info_from_yaml
include LibFish

# TODO move in lib
DirectoriesContainingYamlFishInfo = [
  '../samples/',
  #'buggy-samples/',
  "../en.wikipedia.org/rubycrawl/",
]
DefaultFilesPerDir = 5
# maybe move to models..
# removed: taxo

AllKeys = %w{
taxo
fish_local_url_name
taxo_removeme_debug
wiki
latin_name
proper-description
name
picture_url
binomial_name
simple_description_p4
short_taxo
taxon_identifiers
valid
name_with_short_taxo
}
InterestingTaxoFields = %w{
  latin_name
  wiki taxo
  fish_local_url_name
  title_name
  name_with_short_taxo
  valid
  taxo_removeme_debug
}

def extract_from_yaml_file_relevant_fields(file, interesting_fields=nil, opts={})
  interesting_fields ||= InterestingTaxoFields
  #pp interesting_fields
  file_content = YAML.load( File.read(file))
  #puts file_content.keys
  h = file_content
  ret = WikiAnimal.create(
    name: h['name'],
    latin: h['latin_name'],
    short_taxo: h['short_taxo'],
    wiki_url: h['wiki'],
    title: h['title_name'],
    wiki_description: h['simple_description_p4'],
    #internal_description: h['proper-description'],
    internal_description: h['taxo_removeme_debug'],
    picture_url: h['picture_url'],
    parse_version: "1.1_230125", # manhouse here, hsould be above.
  )
  puts ret
  file_content.slice(*interesting_fields) # OH WOW! this works: .slice("taxo", "wiki", 'latin'), you need to unpack the array as list of function args :)
  #file_content#.slice(*interesting_fields) # OH WOW! this works: .slice("taxo", "wiki", 'latin'), you need to unpack the array as list of function args :)
end

def main
  max_files_per_dir = ENV.fetch('MAX_FILES_PER_DIR', DefaultFilesPerDir).to_i
  puts 'Now parsing all your dirs for YAML files'
  DirectoriesContainingYamlFishInfo.each do |dir|
    puts("== DIR #{dir} ==".colorize(:white))
    yaml_files = Dir.glob("#{dir}/*.ric.yaml").first(max_files_per_dir)
    puts "#{dir}: #{yaml_files.size} YAML files found."
    yaml_files.each do |file|
      #puts(file.to_s)
      h = extract_from_yaml_file_relevant_fields(file)
      puts h
      # Now lets put some NICE string rep with colors :)
      #puts "🍣 [#{file.split('/').last.to_s.colorize :gray}]\t#{h['name_with_short_taxo'].colorize :cyan} #{h['latin_name'].to_s.colorize :gray} 🌎 #{h['wiki']}"
      ret = WikiAnimal.create(
        #(name: "Luke", movie: movies.first)
        #wiki: https://en.wikipedia.org/wiki/Actinopterygii
        name: h['name'],
        latin: h['latin_name'],
        short_taxo: h['short_taxo'],
        wiki_url: h['']
      ).save
      puts ret.to_s
    end
  end

  puts "🎏 Total animals: #{WikiAnimal.all.count.to_s.colorize :blue}"

end


main()
