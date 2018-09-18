class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      
      #the provider
      t.column :providerendpoint_id, :int, :null => false
      t.column :provider_account_id, :int, :null => false
      
      #textual information
      t.column :contractname, :string
      t.column :contractrights, :string
      t.column :contractfulllegal, :longtext
      
      #condition config #other values = N
      t.column :limit_hits, :string, :default => 'Y'     
      t.column :limit_stored, :string, :default => 'N'
      t.column :limit_transfer, :string, :default => 'N'
      t.column :limit_upload, :string, :default => 'N'
      t.column :limit_download, :string, :default => 'N'
      t.column :limit_cpu, :string, :default => 'N'
 
      #conditions to be checked
      t.column :cond_maxhits_perhour, :int, :default => 0
      t.column :cond_maxhits_perday, :int, :default => 0 
      t.column :cond_maxhits_permonth, :int, :default => 0 
      
      t.column :cond_maxmegabstored_total, :int, :default => 0
      
      t.column :cond_maxmegabtransfer_perhour, :int, :default => 0
      t.column :cond_maxmegabtransfer_perday, :int, :default => 0
      t.column :cond_maxmegabtransfer_permonth, :int, :default => 0
      
      t.column :cond_maxmegabupload_perhour, :int, :default => 0
      t.column :cond_maxmegabupload_perday, :int, :default => 0
      t.column :cond_maxmegabupload_permonth, :int, :default => 0
      
      t.column :cond_maxmegabdownload_perhour, :int, :default => 0
      t.column :cond_maxmegabdownload_perday, :int, :default => 0
      t.column :cond_maxmegabdownload_permonth, :int, :default => 0
      
      t.column :cond_maxcpuunits_perhour, :int, :default => 0
      t.column :cond_maxcpuunits_perday, :int, :default => 0
      t.column :cond_maxcpuunits_permonth, :int, :default => 0
      
      t.column :cond_hitdefinition, :string, :default => 'One API method call.'
      
      #pricing model #other values = FREE, PERUNIT
      t.column :billing_model, :string, :default => 'Flat' 
      
      #costs
      t.column :cost_total_onetime, :int, :default => 0
      t.column :cost_permonth, :int
      t.column :cost_per_extrahit, :int, :default => 0
      t.column :cost_per_extra_megab_stored, :int, :default => 0
      t.column :cost_per_extra_megab_transfered, :int, :default => 0
      t.column :cost_per_extra_megab_upload, :int, :default => 0
      t.column :cost_per_extra_megab_download, :int, :default => 0
      
      t.column :backend_template_id, :string
      t.column :trial_period_days, :int
      t.column :currency, :string, :default => 'EUR'
      
      #status
      t.column :cstatus, :string, :default => 'OFFER'
      t.column :ctrial, :boolean, :default => false
      t.column :viewstatus, :string, :default => 'PRIVATE'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :contracts
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
