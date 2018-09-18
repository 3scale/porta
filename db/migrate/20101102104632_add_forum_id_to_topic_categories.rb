class AddForumIdToTopicCategories < ActiveRecord::Migration
  def self.up
    add_column :topic_categories, :forum_id, :integer
    add_index :topic_categories, :forum_id
  end

  def self.down
    remove_column :topic_categories, :forum_id
  end
end
