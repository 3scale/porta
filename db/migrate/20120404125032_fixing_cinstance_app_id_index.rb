class FixingCinstanceAppIdIndex < ActiveRecord::Migration
  def self.up
    remove_index :cinstances, [:application_id, :tenant_id]
  end

  def self.down
    add_index :cinstances, [:application_id, :tenant_id], :unique => true
  end
end
