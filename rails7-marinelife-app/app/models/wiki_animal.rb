class WikiAnimal < ApplicationRecord
  # TODO - within a certain version
  #  validates_uniqueness_of :latin, :name, :wiki_url, :short_taxo, :title
  validates_uniqueness_of :name

  def to_s
    name
  end
end
