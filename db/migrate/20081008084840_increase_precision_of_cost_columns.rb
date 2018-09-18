class IncreasePrecisionOfCostColumns < ActiveRecord::Migration
  def self.up
    change_table :pricing_rules do |t|
      t.change :cost_per_unit, :decimal, :precision => 20, :scale => 4
    end

    change_table :payment_items do |t|
      t.change :cost, :decimal, :precision => 20, :scale => 4
    end

    change_table :contracts do |t|
      t.change :cost_per_month, :decimal, :precision => 20, :scale => 4
    end
  end

  def self.down
    # I gues there is no need to rollback these...
  end
end
