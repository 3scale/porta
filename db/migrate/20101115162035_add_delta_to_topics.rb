class AddDeltaToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :delta, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :topics, :delta
  end
end
