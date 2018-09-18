class ChangeTypeOfStickyInTopicsToBoolean < ActiveRecord::Migration
  def self.up
    change_column :topics, :sticky, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :topics, :sticky, :int, :null => true, :default => 0
  end
end
