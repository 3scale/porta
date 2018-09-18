class AddProxyConfigsToProvider < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.has_attached_file :proxy_configs
    end

  end

  def self.down
    drop_attached_file :accounts, :proxy_configs
  end
end
