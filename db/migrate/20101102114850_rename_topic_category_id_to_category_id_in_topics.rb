class RenameTopicCategoryIdToCategoryIdInTopics < ActiveRecord::Migration
  def self.up
    rename_column :topics, :topic_category_id, :category_id
  end

  def self.down
    rename_column :topics, :category_id, :topic_category_id
  end
end
