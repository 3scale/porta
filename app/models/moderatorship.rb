class Moderatorship < ApplicationRecord
  belongs_to :user
  belongs_to :forum
  validates :user_id, :forum_id, presence: true
  validate :uniqueness_of_relationship

  protected

  def uniqueness_of_relationship
    if self.class.exists?(:user_id => user_id, :forum_id => forum_id)
      errors.add(:base, "Cannot add duplicate user/forum relation")
    end
  end
end
