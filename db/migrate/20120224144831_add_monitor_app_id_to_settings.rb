class AddMonitorAppIdToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :monitor_api_id, :string
    add_column :settings, :monitor_app_id, :string

    [:monitor_api_id, :monitor_app_id].each do |column|
      execute %{
        UPDATE settings
        LEFT JOIN configuration_values ON settings.account_id = configurable_id
        SET settings.#{column} = configuration_values.value
        WHERE configurable_type = "Account" AND configuration_values.name = "#{column}"
      }
    end
  end

  def self.down
    remove_column :settings, :monitor_api_id
    remove_column :settings, :monitor_app_id
  end
end
