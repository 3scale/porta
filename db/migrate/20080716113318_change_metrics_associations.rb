class ChangeMetricsAssociations < ActiveRecord::Migration
  def self.up
    change_table :metrics do |t|
      t.remove_belongs_to :contract
      t.belongs_to :service
    end

    create_table :contracts_metrics, :id => false do |t|
      t.integer :contract_id
      t.integer :metric_id
    end

    change_table :usage_limits do |t|
      t.belongs_to :contract
    end

    change_table :pricing_rules do |t|
      t.belongs_to :contract
    end
  end

  def self.down
    change_table :pricing_rules do |t|
      t.remove_belongs_to :contract
    end

    change_table :usage_limits do |t|
      t.remove_belongs_to :contract
    end

    drop_table :contracts_metrics

    change_table :metrics do |t|
      t.belongs_to :contract
      t.remove_belongs_to :service
    end
  end
end
