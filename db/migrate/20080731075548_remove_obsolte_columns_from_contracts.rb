class RemoveObsolteColumnsFromContracts < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.remove :limit_hits
      t.remove :limit_stored
      t.remove :limit_transfer
      t.remove :limit_upload
      t.remove :limit_download
      t.remove :limit_cpu

      t.remove :cond_maxhits_perhour
      t.remove :cond_maxhits_perday
      t.remove :cond_maxhits_permonth
      t.remove :cond_maxmegabstored_total
      t.remove :cond_maxmegabtransfer_perhour
      t.remove :cond_maxmegabtransfer_perday
      t.remove :cond_maxmegabtransfer_permonth
      t.remove :cond_maxmegabupload_perhour
      t.remove :cond_maxmegabupload_perday
      t.remove :cond_maxmegabupload_permonth
      t.remove :cond_maxmegabdownload_perhour
      t.remove :cond_maxmegabdownload_perday
      t.remove :cond_maxmegabdownload_permonth
      t.remove :cond_maxcpuunits_perhour
      t.remove :cond_maxcpuunits_perday
      t.remove :cond_maxcpuunits_permonth
      t.remove :cond_hitdefinition

      t.remove :billing_model

      t.rename :cost_permonth, :cost_per_month
      
      t.remove :cost_total_onetime
      t.remove :cost_per_extrahit
      t.remove :cost_per_extra_megab_stored
      t.remove :cost_per_extra_megab_transfered
      t.remove :cost_per_extra_megab_upload
      t.remove :cost_per_extra_megab_download
    end
  end

  def self.down
    change_table :contracts do |t|
      t.string :limit_hits
      t.string :limit_stored
      t.string :limit_transfer
      t.string :limit_upload
      t.string :limit_download
      t.string :limit_cpu
      
      t.integer :cond_maxhits_perhour
      t.integer :cond_maxhits_perday
      t.integer :cond_maxhits_permonth
      t.integer :cond_maxmegabstored_total
      t.integer :cond_maxmegabtransfer_perhour
      t.integer :cond_maxmegabtransfer_perday
      t.integer :cond_maxmegabtransfer_permonth
      t.integer :cond_maxmegabupload_perhour
      t.integer :cond_maxmegabupload_perday
      t.integer :cond_maxmegabupload_permonth
      t.integer :cond_maxmegabdownload_perhour
      t.integer :cond_maxmegabdownload_perday
      t.integer :cond_maxmegabdownload_permonth
      t.integer :cond_maxcpuunits_perhour
      t.integer :cond_maxcpuunits_perday
      t.integer :cond_maxcpuunits_permonth
      t.string :cond_hitdefinition

      t.string :billing_model
      
      t.rename :cost_per_month, :cost_permonth
      
      t.integer :cost_total_onetime
      t.integer :cost_per_extrahit
      t.integer :cost_per_extra_megab_stored
      t.integer :cost_per_extra_megab_transfered
      t.integer :cost_per_extra_megab_upload
      t.integer :cost_per_extra_megab_download
    end
  end
end
