class ChangeDefaultValueOfMinInPricingRules < ActiveRecord::Migration
  def self.up
    change_table :pricing_rules do |t|
      t.change_default :min, 1
    end

    execute('UPDATE pricing_rules SET min = 1 WHERE min <= 0')
  end

  def self.down
    change_table :pricing_rules do |t|
      t.change_default :min, 0
    end
  end
end
