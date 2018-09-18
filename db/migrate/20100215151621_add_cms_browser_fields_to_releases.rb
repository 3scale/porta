class AddCmsBrowserFieldsToReleases < ActiveRecord::Migration
  def self.up
    #TODO is the version field of releases creating missunderstanding in UI with BrowserCMS version field?

    #at the moment we are not using these
    # add_column :version, :integer
    # add_column :lock_version, :integer,  :default => 0

    add_column :releases, :deleted, :boolean, :default => false
    add_column :releases, :published, :boolean, :default => false
    add_column :releases, :archived, :boolean, :default => false

    add_column :releases, :created_by, :integer
    add_column :releases, :updated_by, :integer

    add_column :releases, :slug, :string

    #ContentType.create!(:name => "Release", :group_name => "Release")
  end

  def self.down
    remove_column :releases, :deleted
    remove_column :releases, :published
    remove_column :releases, :archived

    remove_column :releases, :created_by
    remove_column :releases, :updated_by

    remove_column :releases, :slug

    #ContentType.delete_all(['name = ?', 'Release'])
    #CategoryType.all(:conditions => ['name = ?', 'Release']).each(&:destroy)
  end
end
