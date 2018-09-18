class AddBrandingSwitchToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :branding_switch, :string
    execute %{ UPDATE settings SET branding_switch = 'visible' }
    change_column_null :settings, :branding_switch, false
  end

  def self.down
    remove_column :settings, :branding_switch
  end
end
