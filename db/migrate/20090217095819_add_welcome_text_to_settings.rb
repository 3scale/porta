class AddWelcomeTextToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :welcome_text, :text
  end

  def self.down
    remove_column :settings, :welcome_text
  end
end
