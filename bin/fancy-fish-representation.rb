#!/usr/bin/env ruby

require 'colorize'
require_relative '../lib/lib_fish.rb'
require 'yaml'

#from LibFish include fish_info_from_yaml
include LibFish

# TODO move in lib
DirectoriesContainingYamlFishInfo = [
  'samples/',
  #'buggy-samples/',
  "en.wikipedia.org/rubycrawl/",
]
DefaultFilesPerDir = 5
# maybe move to models..
# removed: taxo

InterestingTaxoFields = %w{
  latin_name
  wiki taxo
  fish_local_url_name
  title_name
  name_with_short_taxo
  valid
}

def extract_from_yaml_file_relevant_fields(file, interesting_fields=nil, opts={})
  interesting_fields ||= InterestingTaxoFields
  #pp interesting_fields
  file_content = YAML.load( File.read(file))
  puts file_content
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
      # Now lets put some NICE string rep with colors :)
      puts "🍣 [#{file.split('/').last.to_s.colorize :gray}]\t#{h['name_with_short_taxo'].colorize :cyan} #{h['latin_name'].to_s.colorize :gray} 🌎 #{h['wiki']}"
      puts h
    end
  end
end


main()
