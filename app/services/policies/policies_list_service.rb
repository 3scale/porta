# frozen_string_literal: true

require 'jsonclient'
require 'set'

class Policies::PoliciesListService
  class PoliciesListServiceError < StandardError; end

  HTTP_ERRORS = [HTTPClient::BadResponseError,HTTPClient::TimeoutError, HTTPClient::ConnectTimeoutError,
                 HTTPClient::SendTimeoutError, HTTPClient::ReceiveTimeoutError, SocketError,
                 Errno::ECONNREFUSED].freeze
  SERVICE_CALL_ERRORS = [PoliciesListServiceError, *HTTP_ERRORS].freeze
  private_constant :HTTP_ERRORS, :SERVICE_CALL_ERRORS

  def self.call(*args)
    new(*args).call
  end

  def self.call!(*args)
    new(*args).call!
  end

  attr_reader :account, :proxy, :builtin
  alias builtin? builtin

  delegate :self_managed?, to: :proxy, allow_nil: true
  delegate :provider_can_use?, :policies, to: :account, allow_nil: true


  # This smells :reek:BooleanParameter
  def initialize(account, builtin: true, proxy: nil)
    @account = account
    @proxy = proxy
    @builtin = builtin
  end

  def apicast_registry_url
    url = self_managed? ? :self_managed_apicast_registry_url : :apicast_registry_url
    ThreeScale.config.sandbox_proxy.public_send(url)
  end

  def call
    call!
  rescue *SERVICE_CALL_ERRORS => error
    Rails.logger.error { error } and return
  end

  def call!
    list = PolicyList.new
    list.merge! fetch_policies_from_apicast if builtin?
    list.merge! policies_from_account
    list.to_h
  end

  private

  def fetch_policies_from_apicast
    begin
      response = ::JSONClient.get(apicast_registry_url)
    rescue *HTTP_ERRORS => error
      error_message = 'Please provide an apicast registry url in your configuration.' if apicast_registry_url.blank?
      raise_policies_list_error(error_message || error.message)
    end
    raise_policies_list_error(response.content) unless response.ok?
    response.body['policies']
  end

  def raise_policies_list_error(error)
    raise PoliciesListServiceError, I18n.t('errors.messages.apicast_not_found', url: apicast_registry_url.presence || ' ', error: error)
  end

  def policies_from_account
    return unless provider_can_use?(:policy_registry)
    PolicyList.new(policies) if self_managed?
  end

  class PolicyList
    include Enumerable

    attr_reader :sets
    protected :sets
    delegate :each, to: :sets

    def initialize(policies = [])
      @sets = Hash.new { |hash, key| hash[key] = Set.new }
      policies.each(&method(:add))
    end

    # This smells :reek:FeatureEnvy
    # but it is OK
    def add(policy)
      @sets[policy.name.to_s].add(policy.schema)
    end

    def merge(other)
      object = dup
      object.merge!(other)
      object
    end

    def merge!(other)
      return self if other.blank?

      other.each do |key, value|
        @sets[key] = @sets[key] + value
      end

      self
    end

    def initialize_copy(source)
      super
      @sets = source.sets.dup
    end

    def self.from_hash(hash)
      object = new
      object.merge!(hash.as_json)
      object
    end

    def to_h
      @sets.transform_values(&:to_a).as_json
    end
  end
end
