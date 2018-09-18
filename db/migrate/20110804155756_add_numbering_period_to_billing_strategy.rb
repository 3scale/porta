class AddNumberingPeriodToBillingStrategy < ActiveRecord::Migration
  def self.up
    add_column :billing_strategies, :numbering_period, :string, :default => 'monthly'
  end

  def self.down
    remove_column :billing_strategies, :numbering_period
  end
end
