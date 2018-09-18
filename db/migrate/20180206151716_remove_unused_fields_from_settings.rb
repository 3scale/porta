class RemoveUnusedFieldsFromSettings < ActiveRecord::Migration
  def change
    remove_column :settings, :monitor_api_id, :string
    remove_column :settings, :monitor_app_id, :string
  end
end
