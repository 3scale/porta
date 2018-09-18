class CreateContractMetrics < ActiveRecord::Migration
  def self.up
    create_table :contract_metrics do |t|
      t.belongs_to :contract
      t.string :name
      t.text :description
      t.string :unit

      t.timestamps
    end
  end

  def self.down
    drop_table :contract_metrics
  end
end
