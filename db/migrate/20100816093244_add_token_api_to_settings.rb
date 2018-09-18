class AddTokenApiToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :token_api, :string, :default => 'default'
  end

  def self.down
    remove_column :settings, :token_api
  end
end
