class AddServicePlansSwitch < ActiveRecord::Migration
  def self.up
    add_column :settings, :service_plans_switch, :string

    Settings.reset_column_information

    Account.providers.find_each do |provider|
      provider.settings.update_attribute( :service_plans_switch, 'visible')
    end

    change_column_null :settings, :service_plans_switch, false
  end

  def self.down
    remove_column :settings, :service_plans_switch
  end
end
