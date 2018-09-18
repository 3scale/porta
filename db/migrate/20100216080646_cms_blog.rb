class CmsBlog < ActiveRecord::Migration
    def self.up
      create_table :blogs do |t|
        t.string :name
        t.string :format
        t.text :template
        t.integer :version
        t.integer :lock_version, :default => 0
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps
      end
      create_table :blog_versions do |t|
        t.string :name
        t.string :format
        t.text :template
        t.integer :blog_id
        t.integer :version
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :version_comment
        t.timestamps
      end

      create_table :blog_group_memberships do |t|
        t.integer :blog_id
        t.integer :group_id
        t.integer :version
        t.integer :lock_version, :default => 0
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :name
        t.timestamps
      end
      create_table :blog_group_membership_versions do |t|
        t.integer :blog_group_membership_id
        t.integer :blog_id
        t.integer :group_id
        t.integer :version
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :name
        t.string :version_comment
        t.timestamps
      end

      create_table :blog_posts do |t|
        t.integer :blog_id
        t.integer :author_id
        t.integer :category_id
        t.string :name
        t.string :slug
        t.text :summary
        t.text :body, :size => (64.kilobytes + 1)
        t.integer :comments_count
        t.datetime :published_at
        t.integer :version
        t.integer :lock_version, :default => 0
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps
      end
      create_table :blog_post_versions do |t|
        t.integer :blog_post_id
        t.integer :blog_id
        t.integer :author_id
        t.integer :category_id
        t.string :name
        t.string :slug
        t.text :summary
        t.text :body, :size => (64.kilobytes + 1)
        t.integer :comments_count
        t.datetime :published_at
        t.integer :version
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :version_comment
        t.timestamps
      end

      create_table :blog_comments do |t|
        t.integer :post_id
        t.string :author
        t.string :email
        t.string :url
        t.string :ip
        t.text :body
        t.integer :version
        t.integer :lock_version, :default => 0
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :name
        t.timestamps
      end
      create_table :blog_comment_versions do |t|
        t.integer :blog_comment_id
        t.integer :post_id
        t.string :author
        t.string :email
        t.string :url
        t.string :ip
        t.text :body
        t.integer :version
        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :name
        t.string :version_comment
        t.timestamps
      end
    end

    def self.down
      drop_table :blog_versions
      drop_table :blogs
      drop_table :blog_post_versions
      drop_table :blog_posts
      drop_table :blog_comment_versions
      drop_table :blog_comments
    end
end
