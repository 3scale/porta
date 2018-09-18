class AddMultipleServicesSwitchToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :multiple_services_switch, :string
    execute %{ UPDATE settings SET multiple_services_switch = 'denied' WHERE can_create_service = 0;}
    execute %{ UPDATE settings SET multiple_services_switch = 'visible' WHERE can_create_service = 1;}
    change_column_null :settings, :multiple_services_switch, false
  end

  def self.down
    remove_column :settings, :multiple_services_switch
  end
end
