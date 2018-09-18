class CreateWebHooks < ActiveRecord::Migration
  def self.up
    create_table :web_hooks do |t|
      t.references :account
      t.string :url
      t.boolean :account_created_on,     :default => false
      t.boolean :account_updated_on,     :default => false
      t.boolean :account_deleted_on,     :default => false
      t.boolean :user_created_on,        :default => false
      t.boolean :user_updated_on,        :default => false
      t.boolean :user_deleted_on,        :default => false
      t.boolean :application_created_on, :default => false
      t.boolean :application_updated_on, :default => false
      t.boolean :application_deleted_on, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :web_hooks
  end
end
