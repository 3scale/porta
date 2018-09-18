class ChangePaperclipFieldsInProfileModel < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :logo_file_name, :profile_logo_file_name
    rename_column :profiles, :logo_content_type, :profile_logo_content_type
    rename_column :profiles, :logo_file_size, :profile_logo_file_size
  end

  def self.down
    rename_column :profiles, :profile_logo_file_size, :logo_file_size
    rename_column :profiles, :profile_logo_content_type, :logo_content_type
    rename_column :profiles, :profile_logo_file_name, :logo_file_name
  end
end
