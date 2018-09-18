class AddIndexesToSlowTables < ActiveRecord::Migration
  def self.up
    add_index :cms_templates_versions, [:template_id, :template_type], :name => 'by_template'
  end

  def self.down
    remove_index :cms_templates_versions, :name => :by_template
  end
end
