class CreateContractRules < ActiveRecord::Migration
  def self.up
    create_table :contract_rules do |t|
      t.belongs_to :metric
      t.integer :min, :null => false, :default => 0
      t.integer :max
      t.decimal :price_per_unit, :precision => 10, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :contract_rules
  end
end
