class KillObsoleteStuff < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE usagestats DROP FOREIGN KEY fk_cinstance_2_id"
    execute "ALTER TABLE usagestatdatas DROP FOREIGN KEY fk_usagestat_id"
    
    drop_table :contracts_metrics
    drop_table :usagestats
    drop_table :usagestatdatas
  end

  def self.down
    create_table :contracts_metrics, :id => false do |t|
      t.integer :contract_id
      t.integer :metric_id
    end
    
    create_table :usagestats do |t|
      t.column :cinstance_id, :int, :null => false
      t.column :viewstatus, :string, :default => 'PRIVATE'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :usagestatdatas do |t|
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
end
