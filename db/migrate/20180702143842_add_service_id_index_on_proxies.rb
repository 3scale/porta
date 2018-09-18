class AddServiceIdIndexOnProxies < ActiveRecord::Migration
  def change
    add_index :proxies, :service_id
  end
end
