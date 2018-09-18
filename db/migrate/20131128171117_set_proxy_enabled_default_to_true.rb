class SetProxyEnabledDefaultToTrue < ActiveRecord::Migration
  def up
    remove_column :proxies, :enabled
  end

  def down
    add_column :proxies, :enabled, :boolean, default: true
  end
end
