class SetForumEnabledDefaultValue < ActiveRecord::Migration
  def self.up
    change_column_default :settings, :forum_enabled, true
  end

  def self.down
    change_column_default :settings, :forum_enabled, false
  end
end
