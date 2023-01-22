
puts '🎏 Importing Fishness MODULE'

module Fishness

=begin
  What is a fish?
  According to https://en.wikipedia.org/wiki/Fish
  95% of fish are https://en.wikipedia.org/wiki/Actinopterygii

=end
  def is_fish_by_name?(fishname)
    true
  end

  def fishness_words
    %w{ maritime marine ocean pelagic sea water }
  end
  # Words which match fishness
  def is_fish_by_wikipedia_content?(content)
    content =~ /Scientific classification/ and
      content =~ /Animalia/ and # and Chordata but can be Mollusc and so on
      content =~ /Phylum/ and # needs a Phylum of some sort
      #content =~ /fish/i
      #content =~ /www.marinespecies.org/
      content =~ /WoRMS/ and #  https://www.marinespecies.org/ WoRMS # eg https://www.marinespecies.org/aphia.php?p=taxdetails&id=105799
      content =~ /ocean/i and
      content =~ /marine\s/i # "marine " but not "marine.com"
      # aquatic/marine
      # AND NOT terrestrial
  end

end
