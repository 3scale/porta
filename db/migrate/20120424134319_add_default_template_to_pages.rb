class AddDefaultTemplateToPages < ActiveRecord::Migration
  def self.up
    change_column_default :pages, :template_file_name, 'main_layout.liquid'
  end

  def self.down
    change_column_default :pages, :template_file_name, nil
  end
end
