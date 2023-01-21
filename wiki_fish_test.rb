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
def print_table(fishname)
    puts "== 🔟📚 #{fishname.colorize :yellow} 📚 =="
    #puts $fish_tables[fishname].rows.sort_by { |e| -e[0] }
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
    #table = Text::Table.new
    # table.head = ['Desired values', 'Current values']
    # table.rows = [['a1', 'b1']]
    # table.rows << ['a2', 'b2']
    #table.rows = [[fish, taxokey, taxoval, result]]
    fish_table_add(fish, taxokey, taxoval, result)
    #puts table.to_s
    print_table(fish) if opts_print_taxo
    
    
    #puts "DEB #{fish}::#{taxokey} -> '#{taxoval}' vs '#{result}'" if opts_verbose
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

    assert_fish_has_taxonomy('Starfish', {
        Kingdom:    :Animalia, 
        Phylum:     :Echinodermata, 
        Superclass: :Asterozoa, 
        Class:      :Asteroidea,
    })

    # Blue Dragon
    assert_fish_has_taxonomy('Glaucus_atlanticus', {
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

end

def assert_fish_has_taxonomy(fishname, taxo_keyvals, opts={})
    puts "== assert_fish_has_taxonomy(#{fishname.colorize :yellow}) =="
    taxo_keyvals.each do |k,v|
        #puts "Testing: #{k}: #{v}"
        assert_single_taxonomy_for_fish_should_be(fishname, k.to_s, v.to_s, opts) # wrong
    end
    print_table(fishname)
end

def testFixturesElegantly()
    fixtures = YAML.load(File.read 'test/fixtures/known_taxonomies.yaml')
    
    myopts = {:exit_after_fail => false,  :verbose => false}

    fixtures['KnownTaxonomisFromWikipedia'].each do |fish_name, fish_buridone|
        #puts fish_name.colorize :yellow # serialization
        #puts fish_buridone
        #puts '--'
        assert_single_taxonomy_for_fish_should_be(fish_name, fish_buridone, myopts)
    end
end

def main()
    #testFixturesElegantly()

    # this should pass already
    assert_single_taxonomy_for_fish_should_be('Gnomefish', 'Kingdom','Animalia') # correct
    assert_single_taxonomy_for_fish_should_be('Gnomefish', 'Family', 'Scombropidae', :verbose => true) # unfortunaterly we get it wrong
    #assert_single_taxonomy_for_fish_should_be('Gnomefish', 'Genus',  'Scombrops') # wrong

    much_better_test_on_taxonomy()
    
    #extract_info_from_wikipedia_page('Dolphin')
end

# main
main()

    # REMOVEME

    # table = Text::Table.new
    # table.head = ['Desired values', 'Current values']
    # table.rows = [['a1', 'b1']]
    # table.rows << ['a2', 'b2']
    # puts table.to_s
    