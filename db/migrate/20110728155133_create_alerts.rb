class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.belongs_to :account, :null => false
      t.timestamp :timestamp, :null => false
      t.string :state, :null => false, :default => 'new'

      t.belongs_to :cinstance, :null => false
      t.decimal :utilization, :precision => 6, :scale => 2, :null => false
      t.integer :level, :alert_id, :null => false
      t.text :message
    end
  end

  def self.down
    drop_table :alerts
  end
end
