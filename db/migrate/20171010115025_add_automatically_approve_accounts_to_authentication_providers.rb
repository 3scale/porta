class AddAutomaticallyApproveAccountsToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :automatically_approve_accounts, :boolean, default: false
  end
end
