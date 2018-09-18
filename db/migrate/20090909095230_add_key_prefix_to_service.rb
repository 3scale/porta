class AddKeyPrefixToService < ActiveRecord::Migration
  def self.up
    add_column :services, :api_key_prefix, :string
  end

  def self.down
    remove_column :services, :api_key_prefix
  end
end
