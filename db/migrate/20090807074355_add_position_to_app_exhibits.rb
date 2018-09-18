class AddPositionToAppExhibits < ActiveRecord::Migration
  def self.up
    add_column :app_exhibits, :position, :integer
  end

  def self.down
    remove_column :app_exhibits, :position
  end
end
