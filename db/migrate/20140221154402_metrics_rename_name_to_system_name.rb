class MetricsRenameNameToSystemName < ActiveRecord::Migration

  def change
    rename_column :metrics, :name, :system_name
  end
end
