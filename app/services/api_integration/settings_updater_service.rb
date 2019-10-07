# frozen_string_literal: true

class ApiIntegration::SettingsUpdaterService
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  class ServiceMismatchError < ActiveRecord::ActiveRecordError; end

  def initialize(service:, proxy:)
    raise ServiceMismatchError unless proxy.service == service
    @service = service
    @proxy = proxy
  end

  attr_reader :service, :proxy

  def valid?
    # It's done this way to get all the errors even if it is already known that is invalid
    [service.valid?, proxy.valid?].all?
  end

  def call!(service_attributes: {}, proxy_attributes: {})
    ActiveRecord::Base.transaction do
      service.update!(service_attributes)
      proxy.update!(proxy_attributes)
    end
    true
  end

  def call(service_attributes: {}, proxy_attributes: {})
    call!(service_attributes: service_attributes, proxy_attributes: proxy_attributes)
    # Done this way so it does the rollback
  rescue ActiveRecord::RecordInvalid
    false
  end

  def errors
    errors = ActiveModel::Errors.new(self)
    proxy.errors.full_messages.each    { |proxy_error|   errors.add(:proxy, proxy_error)     }
    service.errors.full_messages.each  { |service_error| errors.add(:service, service_error) }
    errors
  end

  private

  # ActiveModel::Errors needs this method to read the errors correctly
  def read_attribute_for_validation(attr)
    public_send(attr)
  end
end
