class AddIndexToAlertsOnCinstanceId < ActiveRecord::Migration
  def change
    add_index :alerts, :cinstance_id
  end
end
