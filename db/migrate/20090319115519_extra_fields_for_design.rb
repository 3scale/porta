class ExtraFieldsForDesign < ActiveRecord::Migration
  def self.up
    add_column :settings, :plans_tab_bg_colour, :string
    add_column :settings, :plans_bg_colour, :string
    add_column :settings, :content_border_colour, :string
  end

  def self.down
    remove_column :settings, :content_border_colour
    remove_column :settings, :plans_bg_colour
    remove_column :settings, :plans_tab_bg_colour
  end
end
