class RemoveProviderPrivateKeyFromServices < ActiveRecord::Migration
  def self.up
    remove_column :services, :provider_private_key
  end

  def self.down
    add_column :services, :provider_private_key, :string
  end
end
