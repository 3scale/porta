class FeaturesAvailableForAllPlanTypes < ActiveRecord::Migration
  def self.up
    rename_column :features, :service_id, :featurable_id
    add_column :features, :featurable_type, :string, :null => false, :default => "Service"
    add_column :features, :scope, :string, :null => false, :default => "ApplicationPlan"

    add_index :features, :featurable_type
    add_index :features, [:featurable_type, :featurable_id]
    add_index :features, :scope
  end

  def self.down
    remove_index :features, :featurable_type
    remove_index :features, [:featurable_type, :featurable_id]
    remove_index :features, :scope

    rename_column :features, :featurable_id, :service_id
    remove_column :features, :featurable_type
    remove_column :features, :scope
  end
end
