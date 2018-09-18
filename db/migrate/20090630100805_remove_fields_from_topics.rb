class RemoveFieldsFromTopics < ActiveRecord::Migration
  def self.up
    remove_column :topics, :email
    remove_column :topics, :first_name
    remove_column :topics, :last_name
  end

  def self.down
  end
end
