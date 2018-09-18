class AddIndexUniqueToMetricsSystemName < ActiveRecord::Migration
  def change
    add_index(:metrics, [:service_id, :system_name], unique: true)
  end
end
