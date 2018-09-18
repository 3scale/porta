# TODO: This should be called TopicSubscription
class UserTopic < ApplicationRecord
  belongs_to :user
  belongs_to :topic

  attr_protected :user_id, :topic_id, :tenant_id

  validates :user, presence: true
  validates :topic, presence: true

  validates :user_id, uniqueness: { :scope => :topic_id }
end
