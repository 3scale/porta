class AddIndexToBillingStrategy < ActiveRecord::Migration
  def self.up
    add_index "billing_strategies", "account_id", :name => "index_billing_strategies_on_account_id"
  end

  def self.down
    remove_index "billing_strategies", :name => "index_billing_strategies_on_account_id"
  end
end
