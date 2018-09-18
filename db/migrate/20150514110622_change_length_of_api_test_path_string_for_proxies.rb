class ChangeLengthOfApiTestPathStringForProxies < ActiveRecord::Migration
  def change
    change_column :proxies, :api_test_path, :string, :limit => 8192
  end
end
