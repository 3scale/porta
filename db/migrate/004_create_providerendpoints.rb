class CreateProviderendpoints < ActiveRecord::Migration
  def self.up
    create_table :providerendpoints do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      t.column :account_id, :int, :null => false
      t.column :title, :string, :null => false
      t.column :oneline_description, :text
      t.column :description, :text
      t.column :url_pages_longdescription, :string 
      t.column :url_api, :string 
      t.column :url_support, :string 
      t.column :url_blog, :string 
      t.column :email_support, :string 
      t.column :txt_api, :text 
      t.column :txt_support, :text       
      t.column :txt_features, :text
      t.column :api_type_soap, :boolean, :default => false
      t.column :api_type_rest, :boolean, :default => false
      t.column :api_type_xmlrpc, :boolean, :default => false
      t.column :api_type_javascript, :boolean, :default => false
      t.column :api_type_other, :boolean, :default => false
      t.column :viewstatus, :string, :default => 'PUBLIC'
      t.column :viewstatus, :string, :default => 'PUBLIC'
      t.column :pestatus, :string, :default => 'ACTIVE'
      t.column :provider_key, :string
      t.column :backend_service_id, :string
      t.column :contract_ordering, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :providerendpoints
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
