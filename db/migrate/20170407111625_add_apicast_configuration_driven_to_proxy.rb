class AddApicastConfigurationDrivenToProxy < ActiveRecord::Migration
  def change
    # first set all existing records to "false" and then set new default to "true"
    add_column :proxies, :apicast_configuration_driven, :boolean, null: false, default: false
  end
end
