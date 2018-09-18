class LogEntry < ApplicationRecord

  include ThreeScale::Search::Scopes

  validates :level, :description, :provider, presence: true
  validates :description, length: {maximum: 255}

  TTL = 6.months

  LEVELS = {
    :info => 10,
    :warning => 20,
    :error => 30
  }

  belongs_to :provider, :class_name => "Account"
  belongs_to :buyer, :class_name => "Account"

  scope :by_buyer_query, ->(query) do
    where("buyer_id IN (?) or buyer_id IS NULL", Account.buyers.search_ids(query))
  end

  self.allowed_search_scopes = [:buyer_query]

  def level
    LEVELS.invert[self[:level]]
  end

  def self.log(type, text, provider, buyer)
    entry = create!({ :level => LEVELS[type], :description => text, :buyer => buyer, provider_id: provider.to_param})
    rails_log(type, text)
    entry
  rescue => exception
    System::ErrorReporting.report_error(exception)
  end

  def self.delete_old
    where('created_at < ?', LogEntry::TTL.ago).delete_all
  end

  def description=(text)
    super text.to_s.truncate(column_for_attribute(:description).limit)
  end

  private_class_method def self.rails_log(type, text)
    type = :warn if type == :warning
    Rails.logger.public_send(type, text)
  end

end
