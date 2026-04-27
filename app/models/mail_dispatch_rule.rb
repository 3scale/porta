class MailDispatchRule < ApplicationRecord
  belongs_to :account, inverse_of: :mail_dispatch_rules
  belongs_to :system_operation

  validates :account_id, :system_operation_id, presence: true

  scope :enabled, -> { where(dispatch: true) }

  def self.fetch_with_retry!(options, &block)
    retries = 0

    begin
      # Use find_by + create! directly to avoid transaction wrapper from create_or_find_by!
      # This preserves the old behavior from protected_attributes_continued gem
      # where records created in the block are committed even if the outer create fails
      find_by(options) || create!(options, &block)
    rescue ActiveRecord::RecordNotUnique
      raise if retries > 10

      retries += 1
      retry
    end
  end
end
