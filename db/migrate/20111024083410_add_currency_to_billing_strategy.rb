class AddCurrencyToBillingStrategy < ActiveRecord::Migration
  def self.up
    add_column :billing_strategies, :currency, :string
  end

  def self.down
    remove_column :billing_strategies, :currency
  end
end
