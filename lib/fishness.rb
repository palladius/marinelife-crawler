
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

  def is_fish_by_wikipedia_content?(content)
    content =~ /Scientific classification/ and content =~ /Animalia/ # and Chordata
  end

end
