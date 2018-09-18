class WebHook < ApplicationRecord
  belongs_to :account, :inverse_of => :web_hook

  alias provider account

  attr_protected :account_id, :tenant_id

  validates :account_id, presence: true
  validates :url, format: { :with => URI.regexp(['http', 'https']), :if => :active }, length: { maximum: 255 }

  #TODO: limit association only to providers?
  #TODO validate url as url?
  validates :account_id, uniqueness: true

  class << self
    delegate :perform_deliveries, :sanitized_url, :to => :configuration

    def switchable_attributes
      column_names.select { |attr_name| attr_name.end_with?('_on'.freeze) }
    end

    def configuration
      Rails.configuration.web_hooks
    end
  end

  def ping
    return HTTPClient.get(self.url, :ping => "3scale")
  rescue => e
    # ideally that would raise exception not coming form HTTPClient
    # but as there is no common ancestor, we fallback to Pokemon
    # pattern
    return e
  end

  def enabled?(type, event)
    return false unless active?

    self["#{type}_#{event}_on"]
  end

  protected

  def self.sanitized_url=(url)
    configuration.sanitized_url = url
    Rails.logger.info "Webhooks will always use #{url} instead of the supplied one"
  end

  def self.perform_deliveries=(state)
    configuration.perform_deliveries = state
    Rails.logger.info "Webhooks deliveries are #{state ? 'on' : 'off'}"
  end

end
