class AddSandboxEndpointToProxies < ActiveRecord::Migration
  def change
    add_column :proxies, :sandbox_endpoint, :string
    add_column :proxies, :api_test_path, :string
  end
end
