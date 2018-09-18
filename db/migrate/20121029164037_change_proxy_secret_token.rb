class ChangeProxySecretToken < ActiveRecord::Migration
  def self.up
    change_column :proxies , :secret_token, :string, :default => 'shared secret sent from proxy to API backend'
  end

  def self.down
  end
end
