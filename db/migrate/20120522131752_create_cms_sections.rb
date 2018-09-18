class CreateCmsSections < ActiveRecord::Migration
  def self.up
    create_table :cms_sections do |t|
      t.integer :provider_id, :limit => 8, :null => false
      t.integer :tenant_id, :limit => 8
      t.integer :parent_id, :limit => 8
      t.string :partial_path
      t.string :title
      t.string :system_name

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_sections
  end
end
