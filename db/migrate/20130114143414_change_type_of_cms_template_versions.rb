class ChangeTypeOfCmsTemplateVersions < ActiveRecord::Migration
  def self.up
    CMS::Template::Version.update_all(:type => 'CMS::Template::Version')
  end

  def self.down
  end
end
