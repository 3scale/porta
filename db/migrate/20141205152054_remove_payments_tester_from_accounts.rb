class RemovePaymentsTesterFromAccounts < ActiveRecord::Migration
  def up
    remove_column :accounts, :payments_tester
  end

  def down
    add_column :accounts, :payments_tester, :boolean
  end
end
