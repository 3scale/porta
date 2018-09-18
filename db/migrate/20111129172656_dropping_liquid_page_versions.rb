class DroppingLiquidPageVersions < ActiveRecord::Migration
  def self.up
    # there are some db inconsistencies regarding this table hence the if
    drop_table :liquid_page_versions if table_exists?(:liquid_page_versions)
  end

  def self.down
    create_table "liquid_page_versions", :force => true do |t|
      t.integer  "liquid_page_id"
      t.integer  "version"
      t.integer  "account_id"
      t.string   "title"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "theme_id"
    end

    add_index "liquid_page_versions", ["liquid_page_id"], :name => "index_liquid_page_versions_on_liquid_page_id" 
  end
end
