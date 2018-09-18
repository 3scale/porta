class AddMenuLinkColourToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :menu_link_colour, :string
    #add_column :settings, :content_bg_colour, :string    
  end

  def self.down
    remove_column :settings, :menu_link_colour
    #remove_column :settings, :content_bg_colour
  end
end
