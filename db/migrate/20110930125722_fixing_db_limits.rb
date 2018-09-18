class FixingDbLimits < ActiveRecord::Migration

  # FIXME: these 2 conditions are here so that the migrations run cleanly on connect
  def self.up
    change_column :wiki_pages, :content, :text
    change_column :liquid_page_versions, :content, :text if table_exists?(:liquid_page_versions)
  end

  def self.down
    change_column :wiki_pages, :content, :mediumtext
    change_column :liquid_page_versions, :content, :mediumtext if table_exists?(:liquid_page_versions)
  end
end
