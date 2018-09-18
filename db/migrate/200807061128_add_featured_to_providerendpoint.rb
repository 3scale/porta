class AddFeaturedToProviderendpoint < ActiveRecord::Migration
  def self.up
    add_column :providerendpoints, :featured, :datetime, :default => nil
  end

  def self.down
    remove_column :providerendpoints, :featured
  end
end
