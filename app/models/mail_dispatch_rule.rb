class MailDispatchRule < ApplicationRecord
  belongs_to :account
  belongs_to :system_operation

  validates :account_id, :system_operation_id, presence: true

  scope :enabled, -> { where(dispatch: true) }

  # This is copied from Rails 6 source. We should remove it soon as we move to Rails 6.
  def self.create_or_find_by!(options, &block)
    transaction(requires_new: true) { create!(options, &block) }
  rescue ActiveRecord::RecordNotUnique
    find_by!(options, &block)
  end
end
