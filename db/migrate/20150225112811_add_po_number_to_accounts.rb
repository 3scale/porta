class AddPoNumberToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :po_number, :string
  end
end
