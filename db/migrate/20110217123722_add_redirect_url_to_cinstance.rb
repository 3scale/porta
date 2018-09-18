class AddRedirectUrlToCinstance < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :redirect_url, :text
  end

  def self.down
    remove_column :cinstances, :redirect_url
  end
end
