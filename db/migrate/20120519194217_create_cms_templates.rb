class CreateCmsTemplates < ActiveRecord::Migration
  def self.up
    create_table :cms_templates do |t|
      t.belongs_to :provider, :limit => 8, :null => false
      t.belongs_to :tenant, :limit => 8
      t.belongs_to :section, :limit => 8

      t.string :type
      t.string :path
      t.string :title
      t.string :system_name
      t.column :body, :mediumtext
      t.column :draft, :mediumtext
      t.boolean :liquid_enabled
      t.string :content_type

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_templates
  end
end
