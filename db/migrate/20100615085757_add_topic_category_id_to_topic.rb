class AddTopicCategoryIdToTopic < ActiveRecord::Migration
  def self.up
    add_column :topics, :topic_category_id, :integer
  end

  def self.down
    remove_column :topics, :topic_category_id
  end
end
