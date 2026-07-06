# TODO: This should be called TopicSubscription
class UserTopic < ApplicationRecord
  belongs_to :user
  belongs_to :topic

  validates :user, presence: true
  validates :topic, presence: true

  validates :user_id, uniqueness: { scope: :topic_id, case_sensitive: true }
end
