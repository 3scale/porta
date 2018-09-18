class AddCmsEditModeTokenToAccountSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :cms_token, :string
  end

  def self.down
    remove_column :settings, :cms_token
  end
end
