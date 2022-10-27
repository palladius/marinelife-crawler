# This is a wikipedia imported fish stuff
module WikiFish
  extend ActiveSupport::Concern


  def passes_picky_fish_info_exam(fish_hash)
    puts "[DEB] WikiFish:passes_picky_fish_info_exam() testing concern for given hash"
    #puts "DEB hash keys: #{fish_hash.keys}"
    return false unless fish_hash.has_key? 'name'
    return false unless fish_hash.has_key? 'image'
    return false unless fish_hash.has_key? 'taxo'
#    return false unless fish_hash.has_key? 'latin_name'
    return false unless fish_hash.has_key? 'description'
    true
  end

  def seems_like_a_fish_from_taxo(taxonomy_string)
    is_it = taxonomy_string.match? /Animalia > /
    puts "[DEB] WikiFish:seems_like_a_fish_from_taxo('#{taxonomy_string}') --> #{is_it}"
    is_it
  end

  def is_fish?
    #seems_like_a_fish_from_taxo(self.taxo)
    taxo_looks_like_wikipedia_fish?
  end

  def taxo_looks_like_wikipedia_fish?
    # certamente Animalia > Chordata
    self.taxo.match?(/Agnatha|Cyclostomata|Ostracodermi|Chondrichthyes|Placodermi|AcanthodiiOsteichthyes|Echinodermata| Actinopterygii/i)
  end

  # # makes sure it has all i want...
  # def self.picky_fish_info(fish_hash)
  #   puts "CLASS testing concern picky_fish_info()"
  #   true
  # end

  def created_with_crawler?
    # this shall be refactored soon. For now I can infer from two rthings:
    #1. NAME [wikicrawler] valentin's sharpnose puffer
    #2. private notes:   fish_hash['internal_notes'] = "Created with rake db:seed v#{SeedVersion}"
    internal_notes.to_s.match /^Created with rake db:seed/
  end


end
