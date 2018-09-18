class AddStrongPasswordsEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :strong_passwords_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :strong_passwords_enabled
  end
end
