class Post < ApplicationRecord
  before_validation(:on => :create) { set_forum }
  after_commit(:on => :create) { update_cached_fields }
  after_commit(:on => :destroy) { update_cached_fields }
  after_commit :update_topic_delta_index

  attr_accessible :body, :markup_type, :anonymous_user

  include ThreeScale::SpamProtection::Integration::Model
  has_spam_protection

  # author of post
  belongs_to :user, :counter_cache => true
  belongs_to :topic, :counter_cache => true

  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true

  validates :user_id, presence: { :unless => :anonymous_user? }
  validates :topic_id, :forum_id, :body, presence: true
  validates :body, :body_html, length: { maximum: 65535 }
  validates :email, :first_name, :last_name, length: { maximum: 255 }

  validate :topic_is_not_locked

  delegate :tags, :first_stream, :to => :topic

  scope :oldest_first, -> { order(created_at: :asc) }
  scope :latest_first, -> { order(created_at: :desc) }

  def self.per_page
    # TODO: Isn't 3 too little?
    3
  end

  def name_for_anonymous
    "#{first_name} #{last_name}"
  end

  delegate :name, to: :forum, prefix: true

  def last_in_topic?
    topic.posts.size == 1 && topic.posts.first == self
  end

  def has_user?
    self.user.nil? || self.user.active?
  end

  protected

  def set_forum
    self.forum = topic.forum if topic
  end

  def update_cached_fields
    topic.update_cached_post_fields(self)
  end

  def topic_is_not_locked
    errors.add(:base, "Topic is locked") if topic && topic.locked? && topic.posts_count > 0
  end

  def update_topic_delta_index
    topic.update_attribute(:delta, true)
  end
end
