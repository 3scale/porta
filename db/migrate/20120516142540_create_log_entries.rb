class CreateLogEntries < ActiveRecord::Migration
  def self.up
    create_table :log_entries do |t|
      t.integer :tenant_id, :limit => 8
      t.integer :provider_id, :limit => 8
      t.integer :buyer_id, :limit => 8

      t.integer :level, :default => 10
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :log_entries
  end
end
