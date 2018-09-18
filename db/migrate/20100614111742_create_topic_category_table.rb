class CreateTopicCategoryTable < ActiveRecord::Migration
  def self.up
    create_table :topic_categories, :force => true do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :topic_categories
  end
end
