class IncreaseSizeOfSomeColumns < ActiveRecord::Migration
  def self.up
    change_column :wiki_pages, :content, :mediumtext
    change_column :liquid_pages, :content, :mediumtext
    change_column :liquid_page_versions, :content, :mediumtext
  end

  def self.down
    change_column :wiki_pages, :content, :text
    change_column :liquid_pages, :content, :text
    change_column :liquid_page_versions, :content, :text
  end
end
