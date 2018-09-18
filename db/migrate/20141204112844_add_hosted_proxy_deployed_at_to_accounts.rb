class AddHostedProxyDeployedAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :hosted_proxy_deployed_at, :datetime
  end
end
