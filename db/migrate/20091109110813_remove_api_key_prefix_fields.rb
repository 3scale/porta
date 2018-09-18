class RemoveApiKeyPrefixFields < ActiveRecord::Migration
  def self.up
    remove_column :services, :api_key_prefix
    remove_column :settings, :custom_user_key_prefix_allowed
  end

  def self.down
    add_column :settings, :custom_user_key_prefix_allowed, :boolean
    add_column :service, :api_key_prefix, :string
  end
end
