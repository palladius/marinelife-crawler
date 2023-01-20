#!/usr/bin/env ruby

# todo test forse quando hai internet :) 

require_relative "lib/lib_fish"
require_relative 'lib/string_on_steroids'
require 'yaml'

#require 'minitest'
require 'test/unit/assertions'

include Test::Unit::Assertions 

include LibFish
include StringOnSteroids

#module WikiFishTest

    def assert_taxonomy_for_fish_should_be(fish, taxokey, taxoval, opts={})
        opts_verbose = opts.fetch :verbose, false
        opts_exit_after_fail = opts.fetch :exit_after_fail, true

        result = get_taxonomy_for_fish(fish, taxokey).encode('UTF-8') rescue '' # .to_s.unicode_normalize
        #taxoval = taxoval.encode('UTF-8')
        
        puts "DEB #{fish}::#{taxokey} -> '#{taxoval}' vs '#{result}'" if opts_verbose
        assert_equal(result, taxoval, "Fish #{fish} should have #{taxokey}=#{taxoval}, instead I found '#{result}")
    end

    #myopts = {:exit_after_fail => false,  :verbose => false}
    # this should pass already
    #assert_taxonomy_for_fish_should_be('Gnomefish', 'Kingdom', 'Animalia') # correct
    # this should pass when I fix the test
    #assert_taxonomy_for_fish_should_be('Gnomefish', 'Family', 'Scombropidae', :verbose => true) # unfortunaterly we get it wrong
    #test_taxonomy_for_fish_should_be('Gnomefish', 'Genus', 'Scombrops') # wrong
    #assert_taxonomy_for_fish_should_be('Gnomefish', 'Genus', 'Scombrops') # wrong

    # Gnomefish_tests
#     Kingdom:	Animalia
# Phylum:	Chordata
# Class:	Actinopterygii
# Order:	Perciformes
# Family:	Scombropidae
# Gill, 1862[3]
# Genus:	Scombrops
# Temminck & Schlegel, 1845 [2]

def test_on_taxonomy()
    # starfish
    {Kingdom:    :Animalia, 
     Phylum:     :Echinodermata, 
     Superclass: :Asterozoa, 
     Class:      :Asteroidea,
    }.each do |k,v|
        test_taxonomy_for_fish_should_be('Starfish', k.to_s, v.to_s) # wrong
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
        puts "Testing: #{k}: #{v}"
        taxonomy_for_fish_should_be(fishname, k.to_s, v.to_s, opts) # wrong
    end

end

def testFixturesElegantly()
    fixtures = YAML.load(File.read 'test/fixtures/known_taxonomies.yaml')
    
    myopts = {:exit_after_fail => false,  :verbose => false}

    fixtures['KnownTaxonomisFromWikipedia'].each do |fish_name, fish_buridone|
        #puts fish_name.colorize :yellow # serialization
        #puts fish_buridone
        #puts '--'
        assert_taxonomy_for_fish_should_be(fish_name, fish_buridone, myopts)
    end
end

testFixturesElegantly