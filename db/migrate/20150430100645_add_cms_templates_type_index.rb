class AddCmsTemplatesTypeIndex < ActiveRecord::Migration
  def up
    add_index :cms_templates, :type
  end

  def down
    remove_index :cms_templates, :type
  end
end
