class ProviderConstraints < ApplicationRecord
  NO_LIMIT = Float::INFINITY

  audited allow_mass_assignment: true

  belongs_to :provider, class_name: 'Account'

  def self.null(provider)
    new(provider: provider, max_users: NO_LIMIT, max_services: NO_LIMIT)
  end

  def can_create_service?
    max_services_constraint.can_create?
  end

  def can_create_user?
    max_users_constraint.can_create?
  end

  protected

  def max_users_constraint
    Limit.new(provider.user_count, max_users)
  end

  def max_services_constraint
    Limit.new(provider.service_count, max_services)
  end

  class Limit
    NO_VALUE = Float::INFINITY

    attr_reader :current, :limit

    def initialize(current, limit)
      @current = current || NO_VALUE
      @limit = limit || NO_VALUE
    end

    def can_create?
      current < limit
    end
  end

  delegate :provider_id_for_audits, :to => :account, :allow_nil => true
end
