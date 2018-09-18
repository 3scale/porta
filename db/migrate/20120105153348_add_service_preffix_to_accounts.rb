class AddServicePreffixToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :service_preffix, :string
  end

  def self.down
    remove_column :accounts, :service_preffix, :string
  end
end
