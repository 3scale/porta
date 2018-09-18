class AddTypeToBillingStrategy < ActiveRecord::Migration
  def self.up
    add_column :billing_strategies, :type, :string

    execute "UPDATE billing_strategies SET type = 'Finance::PrepaidBillingStrategy' where prepaid = 1;"
    execute "UPDATE billing_strategies SET type = 'Finance::PostpaidBillingStrategy' where prepaid = 0;"
  end

  def self.down
    remove_column :billing_strategies, :type
  end
end
