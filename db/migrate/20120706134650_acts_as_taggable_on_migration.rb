class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up

    change_table :taggings do |t|
      t.column :tagger_id, :integer
      t.column :tagger_type, :string

      t.remove :taggable_version

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :context, :string

    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]

    execute %{ UPDATE taggings SET context = 'tags' }
  end

  def self.down
    # drop_table :taggings
    # drop_table :tags
  end
end
