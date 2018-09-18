class CreateUsagestatdatas < ActiveRecord::Migration
  def self.up
    create_table :usagestatdatas do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      t.column :usagestat_id, :int, :null => false
      t.column :period_length, :int, :default => 1
      t.column :period_start, :datetime
      t.column :period_end, :datetime
      t.column :hits, :int, :default => 0 
      t.column :megab_stored, :int, :default => 0
      t.column :megab_transfer, :int, :default => 0
      t.column :megab_upload, :int, :default => 0
      t.column :megab_download, :int, :default => 0
      t.column :cpu_units, :int, :default => 0
      t.column :viewstatus, :string, :default => 'PRIVATE'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :usagestatdatas
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
