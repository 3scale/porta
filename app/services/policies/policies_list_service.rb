# frozen_string_literal: true

require 'jsonclient'
require 'set'

class Policies::PoliciesListService

  HTTP_ERRORS = [HTTPClient::BadResponseError, HTTPClient::TimeoutError, HTTPClient::ConnectTimeoutError, HTTPClient::SendTimeoutError, HTTPClient::ReceiveTimeoutError, SocketError].freeze
  private_constant :HTTP_ERRORS

  class PoliciesListServiceError < RuntimeError; end

  def self.call(account, builtin: true)
    list = PolicyList.new
    list.merge! fetch_policies_from_apicast if builtin
    list.merge! policies_from_account(account)
    list.to_h
  rescue *HTTP_ERRORS, PoliciesListServiceError => error
    Rails.logger.error { error } and return
  end

  def self.fetch_policies_from_apicast
    response = ::JSONClient.get(apicast_registry_url)
    raise_policies_list_error(response.content) unless response.ok?
    response.body['policies']
  end

  def self.raise_policies_list_error(error)
    raise PoliciesListServiceError, I18n.t('errors.messages.apicast_not_found', url: apicast_registry_url, error: error)
  end

  def self.policies_from_account(account)
    return unless account.provider_can_use?(:policy_registry)
    PolicyList.new(account.policies)
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
      @sets.deep_merge!(other.to_h) do |_key, values, other_values|
        values + other_values
      end
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

  def self.apicast_registry_url
    ThreeScale.config.sandbox_proxy.apicast_registry_url
  end

  private_class_method :fetch_policies_from_apicast
  private_class_method :raise_policies_list_error
  private_class_method :policies_from_account
end
