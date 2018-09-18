class AddBackendVersionToService < ActiveRecord::Migration
  def self.up
    add_column :services, :backend_version, :string, :default => '2', :null => false
    execute %{
      UPDATE services
      LEFT JOIN configuration_values ON services.account_id = configurable_id
      SET services.backend_version = configuration_values.value
      WHERE configurable_type = "Account" AND configuration_values.name = "backend_version"
    }
  end

  def self.down
    remove_column :services, :backend_version
  end
end
