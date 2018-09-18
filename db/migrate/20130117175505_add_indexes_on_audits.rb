class AddIndexesOnAudits < ActiveRecord::Migration
  def self.up
    add_index :audits, :provider_id
    add_index :audits, :action
    add_index :audits, :version
  end

  def self.down
    remove_index :audits, :provider_id
    remove_index :audits, :action
    remove_index :audits, :version
  end
end
