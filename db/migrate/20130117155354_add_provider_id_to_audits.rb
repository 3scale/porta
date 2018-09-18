class AddProviderIdToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :provider_id, :integer, :limit => 8
  end

  def self.down
    remove_column :audits, :provider_id
  end
end
