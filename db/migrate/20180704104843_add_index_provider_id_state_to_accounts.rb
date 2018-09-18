class AddIndexProviderIdStateToAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, [:provider_account_id, :state]
  end
end
