class AddBrowserCmsFieldsToDownloads < ActiveRecord::Migration
  def self.up
    # add_column :downloads, :name, :string
    add_column :downloads, :deleted, :boolean, :default => false
    # add_column :downloads, :published, :boolean, :default => false
    add_column :downloads, :archived, :boolean, :default => false

    add_column :downloads, :created_by, :integer
    add_column :downloads, :updated_by, :integer

    add_column :downloads, :slug, :string

    #ContentType.create!(:name => "Download", :group_name => "Download")
  end

  def self.down
    # remove_column :downloads, :name
    remove_column :downloads, :deleted
    # remove_column :downloads, :published
    remove_column :downloads, :archived

    remove_column :downloads, :created_by
    remove_column :downloads, :updated_by

    remove_column :downloads, :slug

    #ContentType.delete_all(['name = ?', 'Download'])
    #CategoryType.all(:conditions => ['name = ?', 'Download']).each(&:destroy)
  end
end
