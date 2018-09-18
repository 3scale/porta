class DroppingApplicationsAndApplicationTokens < ActiveRecord::Migration
  def self.up
    drop_table :applications if table_exists?(:applications)
    drop_table :application_tokens if table_exists?(:application_tokens)
  end

  def self.down
    create_table "applications", :force => true do |t|
      t.integer "account_id"
      t.string  "name"
      t.text    "description"
    end
    add_index "applications", ["account_id"], :name => "index_applications_on_account_id" 
    
    create_table "application_tokens", :force => true do |t|
      t.integer  "application_id"
      t.string   "token"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
    end
    add_index "application_tokens", ["application_id"], :name => "index_application_tokens_on_application_id"
  end
end
