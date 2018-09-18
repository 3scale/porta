class TopicCategory < ApplicationRecord
  belongs_to :forum
  #TODO: Rails 4 changes to has_many …, -> { order(…) }
  has_many :topics, -> { sticky_first.last_updated_first }, :foreign_key => :category_id

  attr_protected :forum_id, :tenant_id

  validates :name, presence: true
  validates :name, uniqueness: { :scope => :forum_id }

  default_scope -> { order('name ASC') }
  #scope :with_topics, :include => :topics, :conditions => 'topics.id IS NOT NULL'
  scope :with_topics, -> { joins("INNER JOIN topics ON topic_categories.id = topics.category_id") }

  def has_topics?
    topics.count > 0
  end

end
