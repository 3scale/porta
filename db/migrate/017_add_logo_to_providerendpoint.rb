class AddLogoToProviderendpoint < ActiveRecord::Migration
  def self.up
    add_column :providerendpoints, :logo_file_name, :string
    add_column :providerendpoints, :logo_content_type, :string
    add_column :providerendpoints, :logo_file_size, :integer
  end

  def self.down
    remove_column :providerendpoints, :logo_file_name
    remove_column :providerendpoints, :logo_content_type
    remove_column :providerendpoints, :logo_file_size
  end
end
