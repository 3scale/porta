# frozen_string_literal: true

class ServiceToken < ApplicationRecord
  attr_readonly :service_id, :value

  belongs_to :service, inverse_of: :service_tokens

  after_destroy :create_and_publish_delete_event

  validates :service, presence: true
  validates :value,   presence: true, length: { maximum: 100 }

  delegate :account_id, to: :service, allow_nil: true

  def create_and_publish_delete_event
    ServiceTokenDeletedEvent.create_and_publish!(self)
  end
end
