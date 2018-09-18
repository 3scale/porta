class AddJanrainIdentifierToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :janrain_identifier, :string
  end

  def self.down
    remove_column :users, :janrain_identifier
  end
end
