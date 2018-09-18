class AddSecretTokenToProxy < ActiveRecord::Migration
  def self.up
    add_column :proxies, :secret_token, :string, :null => false
  end

  def self.down
    remove_column :proxies, :secret_token
  end
end
