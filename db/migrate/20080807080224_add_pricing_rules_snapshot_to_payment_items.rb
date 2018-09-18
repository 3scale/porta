class AddPricingRulesSnapshotToPaymentItems < ActiveRecord::Migration
  def self.up
    change_table :payment_items do |t|
      t.text :pricing_rules_snapshot
    end
  end

  def self.down
    change_table :payment_items do |t|
      t.remove :pricing_rules_snapshot
    end
  end
end
