#!/usr/bin/env ruby

require 'colorize'
require_relative '../lib/lib_fish.rb'
require 'yaml'

#from LibFish include fish_info_from_yaml
include LibFish

# TODO move in lib
DirectoriesContainingYamlFishInfo = [
  'samples/',
  'buggy-samples/',
  "en.wikipedia.org/rubycrawl/",
]

# maybe move to models..
# removed: taxo

InterestingTaxoFields = %w{
  latin_name
  wiki
  fish_local_url_name
  title_name
  name_with_short_taxo
}

def extract_from_yaml_file_relevant_fields(file, interesting_fields=nil, opts={})
  interesting_fields ||= InterestingTaxoFields
  #pp interesting_fields
  file_content = YAML.load( File.read(file))
  file_content.slice(*interesting_fields) # OH WOW! this works: .slice("taxo", "wiki", 'latin'), you need to unpack the array as list of function args :)
  #file_content#.slice(*interesting_fields) # OH WOW! this works: .slice("taxo", "wiki", 'latin'), you need to unpack the array as list of function args :)
end

def main
  max_files_per_dir = ENV.fetch('MAX_FILES_PER_DIR', 3).to_i
  puts 'Now parsing all your dirs for YAML files'
  DirectoriesContainingYamlFishInfo.each do |dir|
    puts("== DIR #{dir} ==".colorize(:white))
    yaml_files = Dir.glob("#{dir}/*.ric.yaml").first(max_files_per_dir)
    puts "#{dir}: #{yaml_files.size} YAML files found."
    yaml_files.each do |file|
      puts(file.to_s)
      puts extract_from_yaml_file_relevant_fields(file)
    end
  end
end


main()
