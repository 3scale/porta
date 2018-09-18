class SetApicastConfigurationDrivenDefaultToTrue < ActiveRecord::Migration
  def up
    change_column :proxies, :apicast_configuration_driven, :boolean, default: true
  end

  def down
    change_column :proxies, :apicast_configuration_driven, :boolean, default: false
  end
end
