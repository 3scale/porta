class Moderatorship < ApplicationRecord
  belongs_to :user
  belongs_to :forum
  validates :user_id, :forum_id, presence: true
  validate :uniqueness_of_relationship

  attr_protected :forum_id, :user_id, :tenant_id

  protected

  def uniqueness_of_relationship
    if self.class.exists?(:user_id => user_id, :forum_id => forum_id)
      errors.add(:base, "Cannot add duplicate user/forum relation")
    end
  end
end
