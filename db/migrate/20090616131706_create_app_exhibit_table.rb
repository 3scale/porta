class CreateAppExhibitTable < ActiveRecord::Migration
  def self.up
    create_table :app_exhibits do |t|
      t.belongs_to :account
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.string :title
      t.string :url
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :app_exhibits
  end
  
end
