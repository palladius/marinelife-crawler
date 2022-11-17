#!/usr/bin/env ruby

# todo test forse quando hai internet :) 

require_relative "lib/lib_fish"
require_relative 'lib/string_on_steroids'

#require 'minitest'
require 'test/unit/assertions'

include Test::Unit::Assertions 

include LibFish
include StringOnSteroids

#module WikiFishTest

    def assert_taxonomy_for_fish_should_be(fish, taxokey, taxoval)
        result = get_taxonomy_for_fish(fish, taxokey).encode('UTF-8') # .to_s.unicode_normalize
        #taxoval = taxoval.encode('UTF-8')
        
        puts "DEB #{fish}::#{taxokey} -> '#{taxoval}' vs '#{result}'"
        assert_equal(result, taxoval, "Fish #{fish} should have #{taxokey}=#{taxoval}, instead I found '#{result}")
    end

    # this should pass already
    assert_taxonomy_for_fish_should_be('Gnomefish', 'Kingdom', 'Animalia') # correct
    # this should pass when I fix the test
    assert_taxonomy_for_fish_should_be('Gnomefish', 'Family', 'Scombropidae', :verbose => true) # unfortunaterly we get it wrong
    #test_taxonomy_for_fish_should_be('Gnomefish', 'Genus', 'Scombrops') # wrong
    assert_taxonomy_for_fish_should_be('Gnomefish', 'Genus', 'Scombrops') # wrong

    # stargish
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
        Family:	:Glaucidae,
        Genus:	:Glaucus,
        #Species:	G. atlanticus
    })

#end