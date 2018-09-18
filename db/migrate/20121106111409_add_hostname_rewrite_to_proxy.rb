class AddHostnameRewriteToProxy < ActiveRecord::Migration
  def self.up
    add_column :proxies, :hostname_rewrite, :string
  end

  def self.down
    remove_column :proxies, :hostname_rewrite
  end
end
