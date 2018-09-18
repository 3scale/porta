class AddAlertsIndexes < ActiveRecord::Migration
  def change
    add_index :alerts, :timestamp
  end
end
