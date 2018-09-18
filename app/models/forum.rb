class Forum < ApplicationRecord

  validates :name, presence: true, length: { maximum: 255 }
  validates :description_html, length: { maximum: 65535 }
  validates :description, :state, :permalink,  length: { maximum: 255 }
  
  belongs_to :account
  has_permalink :name

  attr_readonly :posts_count, :topics_count

  has_many :topics, -> { extending Topic::Search }, dependent: :delete_all

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, -> { last_updated_first.of_active_user }, class_name: 'Topic'
  has_one :recent_topic, -> { last_updated_first }, class_name: 'Topic'

  has_many :posts, -> { latest_first }, :dependent => :delete_all
  has_one  :recent_post, -> { latest_first }, :class_name => 'Post'

  has_many :moderatorships, :dependent => :delete_all
  has_many :moderators, :through => :moderatorships, :source => :user

  has_many :categories, :class_name => 'TopicCategory'

  scope :ordered, -> { order('position') }

  attr_protected :topics_count, :posts_count, :account_id, :tenant_id

  def latest_posts
    posts.joins(:topic).order('posts.created_at desc')
  end

  def to_param
    permalink
  end

  def to_s
    name
  end

  def public?
    account.settings.forum_public?
  end

  def anonymous_posts_enabled?
    account.settings.anonymous_posts_enabled?
  end
end
