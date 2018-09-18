class AddApplicationFirstTrafficAt < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :first_traffic_at, :datetime
  end

  def self.down
    remove_column :cinstances, :first_traffic_at
  end
end
