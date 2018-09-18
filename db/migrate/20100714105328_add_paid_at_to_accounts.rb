class AddPaidAtToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :paid_at, :datetime
  end

  def self.down
    remove_column :accounts, :paid_at
  end
end
