class RemoveServicePreffixFromAccounts < ActiveRecord::Migration
  def change
    safety_assured { remove_column :accounts, :service_preffix, :string }
  end
end
