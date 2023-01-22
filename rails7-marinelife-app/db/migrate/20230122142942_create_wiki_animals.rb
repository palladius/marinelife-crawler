class CreateWikiAnimals < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_animals do |t|
      t.string :name
      t.string :latin
      t.string :title
      t.string :wiki_url
      t.string :short_taxo
      t.text :wiki_description
      t.text :internal_description
      t.string :version

      t.timestamps
    end
  end
end
