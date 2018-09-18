class AddTelephoneNumberToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :telephone_number, :string
  end

  def self.down
    remove_column :accounts, :telephone_number
  end
end
