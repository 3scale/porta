class AddCmsTemplatesVersions < ActiveRecord::Migration
  def self.up
    execute %{ CREATE TABLE cms_templates_versions LIKE cms_templates; }

    change_table :cms_templates_versions do |t|
      t.belongs_to :template, :polymorphic => true
    end
  end

  def self.down
    drop_table :cms_templates_versions
  end
end
