class AddAuthenticationStrategy2Settings < ActiveRecord::Migration
  def self.up

    # connect weirdness
    Settings.reset_column_information
    add_column :settings, :authentication_strategy, :string, :null => false, :default => 'internal' unless Settings.column_names.include? "authentication_strategy"


    Account.providers.find_each do |provider|
      provider.settings.update_attribute( :authentication_strategy, bool_switch( provider,:authentication_strategy))
    end

    change_column_null :settings, :authentication_strategy, false
  end

  def self.down
    remove_column :settings, :authentication_strategy
  end

  private

  def self.bool_switch( provider, key)
     provider.config.fetch_deprecated(key)
  end

end
