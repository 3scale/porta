class MergeConnectAndEnterpriseDataModels < ActiveRecord::Migration
  def self.up
    drop_table :liquid_templates if table_exists?(:liquid_templates)
    drop_table :liquid_template_versions if table_exists?(:liquid_template_versions)
    begin
      remove_column :users, :site_id
      remove_column :forums, :site_id
      remove_column :posts, :site_id
      remove_column :topics, :site_id
    rescue # there is no column_exists? in rails 2.3
    end
    drop_table :gateway_logs if table_exists?(:gateway_logs)
    change_column :message_recipients, :receiver_type, :string, :null => false
    change_column :message_recipients, :kind, :string, :null => false
    change_column :message_recipients, :state, :string, :null => false
    change_column :messages, :sender_type, :string, :null => false
    change_column :messages, :state, :string, :null => false
    change_column :html_blocks, :content, :text
    change_column :html_block_versions, :content, :text
  end

  def self.down
    create_table "liquid_templates", :force => true do |t|
      t.integer  "account_id"
      t.string   "name"
      t.text     "content"
      t.integer  "version"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "theme_id"
      t.integer  "tenant_id"
    end

    create_table "liquid_template_versions", :force => true do |t|
      t.integer  "liquid_template_id"
      t.integer  "version"
      t.integer  "account_id"
      t.string   "name"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "theme_id"
      t.integer  "tenant_id"
    end
    add_index "liquid_template_versions", ["liquid_template_id"], :name => "index_liquid_template_versions_on_liquid_template_id"

    add_column :forums, :site_id, :integer
    add_column :posts, :site_id, :integer
    add_column :topics, :site_id, :integer
    add_column :users, :site_id, :integer

    create_table "gateway_logs", :force => true do |t|
      t.integer  "account_id"
      t.string   "gateway"
      t.string   "partial"
      t.text     "action"
      t.text     "response"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
