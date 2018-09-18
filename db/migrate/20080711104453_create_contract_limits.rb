class CreateContractLimits < ActiveRecord::Migration
  def self.up
    create_table :contract_limits do |t|
      t.belongs_to :metric
      t.integer :period
      t.integer :value

      t.timestamps
    end
  end

  def self.down
    drop_table :contract_limits
  end
end
