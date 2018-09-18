class AddCasIdentifierToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cas_identifier, :string, :default => nil
  end

  def self.down
    remove_column :users, :cas_identifier
  end
end
