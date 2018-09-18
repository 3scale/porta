class AddProxiesLockVersionColumn < ActiveRecord::Migration
  def change
    add_column :proxies, :lock_version, :integer, limit: 8, default: 0, null: false
  end
end
