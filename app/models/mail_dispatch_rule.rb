class MailDispatchRule < ApplicationRecord
  belongs_to :account
  belongs_to :system_operation

  validates :account_id, :system_operation_id, presence: true

  scope :enabled, -> { where(dispatch: true) }

  def self.fetch_with_retry!(options, &block)
    retries = 0

    begin
      MailDispatchRule.find_or_create_by!(options, &block)
    rescue ActiveRecord::RecordNotUnique
      if retries > 10
        raise
      else
        retries += 1
        retry
      end
    end
  end
end
