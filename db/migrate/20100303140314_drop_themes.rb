class DropThemes < ActiveRecord::Migration
  def self.up
    drop_table :themes
  end

  def self.down
    create_table :themes do |table|
      table.string :title
      table.timestamps
    end
  end
end
