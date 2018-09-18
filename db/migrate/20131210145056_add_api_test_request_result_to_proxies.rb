class AddApiTestRequestResultToProxies < ActiveRecord::Migration
  def change
    add_column :proxies, :api_test_success, :boolean
  end
end
