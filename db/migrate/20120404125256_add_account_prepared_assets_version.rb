class AddAccountPreparedAssetsVersion < ActiveRecord::Migration
  def self.up
    add_column :accounts, :prepared_assets_version,  :integer
  end

  def self.down
    remove_column :accounts, :prepared_assets_version
  end
end
