class AddHeadersToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :headers, :text
  end

  def self.down
    remove_column :messages, :headers
  end
end
