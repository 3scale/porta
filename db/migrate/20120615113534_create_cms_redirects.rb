class CreateCmsRedirects < ActiveRecord::Migration
  def self.up
    create_table :cms_redirects do |t|
      t.belongs_to :provider, :limit => 8, :null => false

      t.string :source, :null => false
      t.string :target, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_redirects
  end
end
