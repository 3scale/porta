class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      t.column :account_id, :int, :null => false
      t.column :oneline_description, :string, :null => false
      t.column :description, :text
      t.column :company_url, :string
      t.column :blog_url, :string
      t.column :rssfeed_url, :string
      t.column :email_sales, :string
      t.column :email_techsupport, :string
      t.column :email_press, :string
      t.column :viewstatus, :string, :default => 'PRIVATE'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :profiles
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
