class ChangeDefaultCurrencyToEurInAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.change_default :currency, 'EUR'
    end
  end

  def self.down
  end
end
