class AddSpamProtectionLevelSetting < ActiveRecord::Migration
  def self.up
    add_column :settings, :spam_protection_level, :string, :null => false, :default => 'none'
  end

  def self.down
    remove_column :settings, :spam_protection_level
  end
end
