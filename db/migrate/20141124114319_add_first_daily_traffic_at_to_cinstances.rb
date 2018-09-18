class AddFirstDailyTrafficAtToCinstances < ActiveRecord::Migration
  def change
    add_column :cinstances, :first_daily_traffic_at, :datetime
  end
end
