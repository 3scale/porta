class RenameProfileLogoToLogoInProfiles < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.rename :profile_logo_file_name, :logo_file_name
      t.rename :profile_logo_file_size, :logo_file_size
      t.rename :profile_logo_content_type, :logo_content_type
    end
  end

  def self.down
    change_table :profiles do |t|
      t.rename :logo_file_name, :profile_logo_file_name
      t.rename :logo_file_size, :profile_logo_file_size
      t.rename :logo_content_type, :profile_logo_content_type
    end
  end
end
