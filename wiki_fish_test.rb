#!/usr/bin/env ruby

# todo test forse quando hai internet :)

require_relative "lib/lib_fish"
require_relative 'lib/string_on_steroids'
require 'yaml'
require 'text-table'


#require 'minitest'
require 'test/unit/assertions'

include Test::Unit::Assertions
include LibFish
include StringOnSteroids

#module WikiFishTest

$fish_tables = {}

def initialise_fish_table(fishname)
    if $fish_tables.key?(fishname)
        #puts "DEB keys already exists"
    else
        $fish_tables[fishname] = Text::Table.new()
        $fish_tables[fishname].head = ['Key', 'Desired value', 'Current value']
        #$fish_tables[fishname].rows << [{:value => "🐠 #{fishname}", :colspan => 3, :align => :center}]
    end
end
def fish_table_add(fishname, taxokey, taxoval, realval)
    initialise_fish_table(fishname)
    $fish_tables[fishname].rows << [taxokey, taxoval, realval]
end
def print_table(fishname, opts={})
    opts_skip_title = opts.fetch :skip_title , false

    puts "== 🔟📚 #{fishname.colorize :yellow} 📚 ==" unless opts_skip_title
    $fish_tables[fishname].rows.sort_by! { |e| -e[0] }
    puts $fish_tables[fishname].to_s
end

# this computes a single taxonomy check
def assert_single_taxonomy_for_fish_should_be(fish, taxokey, taxoval, opts={})
    opts_verbose = opts.fetch :verbose, true
    # opts_print_taxo should be FALSE (unless debug) since you might call the SINGLE many times. You want to print LATER.
    opts_print_taxo = opts.fetch :verbose, false
    opts_exit_after_fail = opts.fetch :exit_after_fail, false # TODO true

    # This code is far away: in `./lib/lib_fish.rb`
    result = get_taxonomy_for_fish(fish, taxokey).encode('UTF-8') rescue '' # .to_s.unicode_normalize
    #taxoval = taxoval.encode('UTF-8')
    if result == ''
        puts "Empty value for #{fish}::#{taxokey}, let me dig deeper with additioanl verbosity".colorize :red
        puts get_taxonomy_for_fish(fish, taxokey, :verbose => true)
    end

    fish_table_add(fish, taxokey, taxoval, result)
    #print_table(fish) if opts_print_taxo
    puts "DEB #{fish}::#{taxokey} -> '#{taxoval}' vs '#{result}'" if opts_verbose
    assert_equal(result, taxoval, "Fish #{fish} should have #{taxokey}=#{taxoval}, instead I found '#{result}") if opts_exit_after_fail
end

    #myopts = {:exit_after_fail => false,  :verbose => false}

    # Gnomefish_tests
#     Kingdom:	Animalia
# Phylum:	Chordata
# Class:	Actinopterygii
# Order:	Perciformes
# Family:	Scombropidae
# Gill, 1862[3]
# Genus:	Scombrops
# Temminck & Schlegel, 1845 [2]

def much_better_test_on_taxonomy()
    # starfish
    {Kingdom:    :Animalia,
     Phylum:     :Echinodermata,
     Superclass: :Asterozoa,
     Class:      :Asteroidea,
    }.each do |k,v|
        assert_single_taxonomy_for_fish_should_be('Starfish', k.to_s, v.to_s)
        #test_taxonomy_for_fish_should_be('Starfish', k.to_s, v.to_s) # wrong
     end

    assert_fish_has_full_taxonomy('Starfish', {
        Kingdom:    :Animalia,
        Phylum:     :Echinodermata,
        Superclass: :Asterozoa,
        Class:      :Asteroidea,
    })

    assert_fish_has_full_taxonomy('Gnomefish', {
        Kingdom:    :Animalia,
        Phylum:     :Scombropidae,
        Family:     'ti piacerebbe',
        Genus:      'Scombrops',
    })

    #assert_single_taxonomy_for_fish_should_be('Gnomefish', 'Kingdom','Animalia') # correct
    #assert_single_taxonomy_for_fish_should_be('Gnomefish', 'Family', 'Scombropidae', :verbose => true) # unfortunaterly we get it wrong


    # Blue Dragon
    assert_fish_has_full_taxonomy('Glaucus_atlanticus', {
        Kingdom:    :Animalia,
        Phylum:     :Mollusca,
        Class:      :Gastropoda,
        Subclass:	:Heterobranchia,
        Order:	    :Nudibranchia,
        Suborder:	:Cladobranchia,
        Family:	    :Glaucidae,
        Genus:	    :Glaucus,
        #Species:	G. atlanticus,
    })
    assert_fish_has_full_taxonomy('Oceanic_dolphin', {
        Kingdom:    :Animalia,
        Phylum:     :Chordata,
        Class:      :Mammalia,
        Order:	:Artiodactyla,
# Infraorder:	Cetacea
# Superfamily:	Delphinoidea
# Family:	Delphinidae

        #Species:	G. atlanticus,
    })

#     Kingdom:	Animalia
# Phylum:	Chordata
# Class:	Mammalia
# Order:	Artiodactyla
# Infraorder:	Cetacea
# Superfamily:	Delphinoidea
# Family:	Delphinidae
# Gray, 1821

end

def assert_fish_has_full_taxonomy(fishname, taxo_keyvals, opts={})
    puts "== assert_fish_has_full_taxonomy(#{fishname.colorize :yellow}) =="
    taxo_keyvals.each do |k,v|
        assert_single_taxonomy_for_fish_should_be(fishname, k.to_s, v.to_s, opts) # wrong
    end
    print_table(fishname, :skip_title => true) # as its already above..
end

def testFixturesElegantly()
    puts "Now testing FIXTURES from file:".colorize :green
    fixtures = YAML.load(File.read 'test/fixtures/known_taxonomies.yaml')

    myopts = {:exit_after_fail => false,  :verbose => true}

    fixtures['KnownTaxonomisFromWikipedia'].each do |fish_name, fish_buridone|
        assert_fish_has_full_taxonomy(fish_name, fish_buridone, myopts)
    end
end

def main()
    testFixturesElegantly()
    #much_better_test_on_taxonomy()
    #extract_info_from_wikipedia_page('Oceanic_dolphin')
end

# main
main()

    # REMOVEME

    # table = Text::Table.new
    # table.head = ['Desired values', 'Current values']
    # table.rows = [['a1', 'b1']]
    # table.rows << ['a2', 'b2']
    # puts table.to_s
