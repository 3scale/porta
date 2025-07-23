class DropForums < ActiveRecord::Migration[7.0]
  def change
    drop_table :forums
    drop_table :moderatorships
    drop_table :posts
    drop_table :topic_categories
    drop_table :topics
    drop_table :user_topics

    safety_assured do
      remove_columns :settings, :forum_enabled, :forum_public, :anonymous_posts_enabled
      remove_columns :users, :posts_count
    end
  end
end
