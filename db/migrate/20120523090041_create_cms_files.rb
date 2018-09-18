class CreateCmsFiles < ActiveRecord::Migration
  def self.up
    create_table :cms_files do |t|
      t.belongs_to :provider, :length => 8, :null => false
      t.belongs_to :section, :length => 8
      t.belongs_to :tenant, :length => 8

      t.has_attached_file :attachment

      t.string :random_secret

      t.string :path

      t.boolean :downloadable

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_files
  end
end
