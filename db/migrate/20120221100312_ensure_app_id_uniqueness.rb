class EnsureAppIdUniqueness < ActiveRecord::Migration
  def self.up
    remove_index :cinstances, :column => :application_id
    add_index :cinstances, [:application_id, :tenant_id], :unique => true
  end

  def self.down
    remove_index :cinstances, :name => "index_cinstances_on_application_id_and_tenant_id"
    add_index :cinstances, :application_id
  end
end
