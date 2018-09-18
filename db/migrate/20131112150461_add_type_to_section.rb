class AddTypeToSection < ActiveRecord::Migration
  def change
    add_column :cms_sections, :type, :string, default: 'CMS::Section'
  end
end
