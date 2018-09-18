class AddCustomUserKeyPrefixToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :custom_user_key_prefix_allowed, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :custom_user_key_prefix_allowed
  end
end
