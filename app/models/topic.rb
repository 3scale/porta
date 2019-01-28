class Topic < ApplicationRecord

  acts_as_taggable

  include ThreeScale::SpamProtection::Integration::Model
  has_spam_protection

  ORDER_BY = [['Newest post', ''], ["Most views", "hits"], ["Number of posts", "posts_count"]]

  before_validation(:on => :create) { set_default_attributes }

  after_create   :create_initial_post
  before_update  :check_for_moved_forum
  after_update   :set_post_forum_id
  before_destroy :count_user_posts_for_counter_cache
  after_destroy  :update_cached_forum_and_user_counts

  belongs_to :category, :class_name => 'TopicCategory'

  # creator of forum topic
  belongs_to :user

  # creator of recent post
  belongs_to :last_user, :class_name => "User"

  belongs_to :forum, :counter_cache => true
  delegate :account, :account_id, :to => :forum

  has_many :posts, -> { oldest_first }, :dependent => :delete_all
  has_one  :recent_post, -> { latest_first }, :class_name => 'Post'

  has_many :voices, -> { uniq }, :through => :posts, :source => :user

  has_many :user_topics, :dependent => :destroy
  has_many :subscribers, :through => :user_topics, :source => :user

  validates :user_id, presence: { :unless => :anonymous_user }
  validates :forum_id, :title, presence: true
  validates :body, presence: { :on => :create }
  validates :title, :permalink, length: { maximum: 255 }

  scope :order_by, lambda {|param|
                     joins('INNER JOIN posts ON topics.last_post_id = posts.id')
                                   .order((param && ['hits', 'posts_count'].include?(param)) ? "#{param} desc" : 'posts.created_at desc')
                   }
  scope :for_category, lambda { |*args| where(['topic_category_id = ?', args.first || nil]) }

  scope :with_latest_post, -> { joins('INNER JOIN posts ON topics.last_post_id = posts.id')}


  scope :sticky_first, -> { order(sticky: :desc) }
  scope :last_updated_first, -> { order(last_updated_at: :desc) }
  scope :latest_first, -> { order(created_at: :desc) }
  scope :of_active_user, -> { joins(:user).references(:user).merge(User.active) }

  # Topics that have at least one post by the given user.
  def self.with_post_by(user)
    where({:posts => {:user_id => user.to_param}})
           .joins(:posts).group("topics.id")
  end

  attr_accessor :body, :quiz, :quiz_id, :first_name, :last_name, :email, :human, :markup_type, :anonymous_user
  attr_accessible :markup_type, :title, :body, :quiz, :quiz_id, :first_name, :last_name, :email, :tag_list, :anonymous_user, :tag_list

  attr_readonly :posts_count, :hits

  has_permalink :title, :scope => :forum_id

  module Search
    def smart_search(*args)
      # If no search query given, bypass sphinx and return just normal scope.
      # This is not strictly necessary, beacause sphinx would return the same
      # result, but it simplifies testing. We don't have to care about sphinx
      # in tests that don't have searching as their main focus.

      options = args.extract_options!
      query   = args.first

      options[:page]     ||= 1
      options[:per_page] ||= 20

      if query
        # with sphinx
        options = options.reverse_merge(
          star: true,
          sort_mode: :extended,
          order: 'sticky DESC, weight() DESC, last_updated_at DESC'
        )

        search(ThinkingSphinx::Query.escape(query), options)
      else
        # without sphinx
        results = where({})
        results = results.where(options[:with]) if options[:with]
        results = results.order('sticky DESC, last_updated_at DESC')
        results.paginate(options.slice(:page, :per_page))
      end
    end
  end

  def self.find_for_category(category_id, forum, params = {})
    self.for_forum(forum.id).for_category(category_id).order_by(params[:s])
  end

  def within_range?
  end

  def hit!
    self.class.increment_counter :hits, id
  end

  def paged?
    posts_count > Post.per_page
  end

  def last_page
    [(posts_count.to_f / Post.per_page.to_f).ceil.to_i, 1].max
  end

  def update_cached_post_fields(post)
    # these fields are not accessible to mass assignment
    if remaining_post = post.frozen? ? recent_post : post
          update_columns(last_updated_at: remaining_post.created_at, last_user_id: remaining_post.user_id, last_post_id: remaining_post.id)
    else
      self.destroy
    end
  end

  def to_param
    permalink
  end

  protected

  def create_initial_post
    posts.build.tap do |post|
      post.anonymous_user = anonymous_user
      post.body           = body
      post.user           = user
    end.save!
  end

  def set_default_attributes
    self.sticky          ||= 0
    self.last_updated_at ||= Time.now.utc
  end

  def check_for_moved_forum
    old = Topic.find(id)
    @old_forum_id = old.forum_id if old.forum_id != forum_id
    true
  end

  def set_post_forum_id
    return unless @old_forum_id
    posts.update_all :forum_id => forum_id
    Forum.update_all "posts_count = posts_count - #{posts_count}", ['id = ?', @old_forum_id]
    Forum.update_all "posts_count = posts_count + #{posts_count}", ['id = ?', forum_id]
  end

  def count_user_posts_for_counter_cache
    @user_posts = posts.unscope(:order).where.not(user_id: nil).group(:user_id).count
  end

  def update_cached_forum_and_user_counts
    forum.update_attributes(posts_count: "posts_count - #{posts_count}")

    @user_posts.each do |user_id, posts_size|
      User.find(user_id).update_attributes(posts_count: "posts_count - #{posts_size}")
    end
  end

end
