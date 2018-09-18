class CreateCmsGroups < ActiveRecord::Migration
  def self.up
    create_table :cms_groups do |t|
      t.integer :tenant_id, :limit => 8
      t.integer :account_id, :limit => 8
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_groups
  end
end
