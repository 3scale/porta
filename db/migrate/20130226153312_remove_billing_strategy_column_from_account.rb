class RemoveBillingStrategyColumnFromAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :billing_strategy
  end
end
