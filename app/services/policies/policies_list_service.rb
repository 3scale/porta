# frozen_string_literal: true

require 'jsonclient'
require 'set'

class Policies::PoliciesListService
  def self.call(account)
    response = ::JSONClient.get(ThreeScale.config.sandbox_proxy.apicast_registry_url)
    return unless response.ok?
    list = PolicyList.from_hash(response.body['policies'])
    list.merge!(PolicyList.new(account.policies)) if account.provider_can_use?(:policy_registry)
    list.to_h
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
end
