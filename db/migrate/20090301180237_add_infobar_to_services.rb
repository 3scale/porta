class AddInfobarToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :infobar, :text
  end

  def self.down
    remove_column :services, :infobar
  end
end
