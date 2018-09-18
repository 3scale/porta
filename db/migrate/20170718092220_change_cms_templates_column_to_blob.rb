class ChangeCMSTemplatesColumnToBlob < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        [:cms_templates, :cms_templates_versions].each do |table_name|
          [:draft, :published].each do |column_name|
            execute "ALTER TABLE %s MODIFY %s mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" % [table_name, column_name]
          end
        end
      end

      direction.down do
        [:cms_templates, :cms_templates_versions].each do |table_name|
          [:draft, :published].each do |column_name|
            execute "ALTER TABLE %s MODIFY %s mediumtext CHARACTER SET utf8 COLLATE utf8_unicode_ci;" % [table_name, column_name]
          end
        end
      end
    end
  end
end
