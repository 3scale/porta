class DeprecateConfigurationsTable < ActiveRecord::Migration
  def self.up
    add_column :settings, :multiple_applications_switch, :string
    add_column :settings, :multiple_users_switch, :string
    add_column :settings, :finance_switch, :string

    Settings.reset_column_information
    Service.reset_column_information

    Account.providers.find_each do |provider|
      provider.settings.update_attribute( :multiple_applications_switch, 'visible')
      provider.settings.update_attribute( :multiple_users_switch, 'visible')
      provider.settings.update_attribute( :finance_switch, 'visible')
    end

    change_column_null :settings, :multiple_applications_switch, false
    change_column_null :settings, :multiple_users_switch, false
    change_column_null :settings, :finance_switch, false
  end

  def self.down
    remove_column :settings, :multiple_applications_switch
    remove_column :settings, :multiple_users_switch
    remove_column :settings, :finance_switch
    remove_column :services, :backend_version
  end

  private

  def self.bool_switch( provider, key)
    if provider.config.fetch_deprecated(key)
      'visible'
    else
      'denied'
    end
  end

end
