class AddPositionToWikiPages < ActiveRecord::Migration

  def self.up
    add_column :wiki_pages, :position, :integer
  end

  def self.down
    remove_column :wiki_pages, :position
  end

end

