# frozen_string_literal: true

class PlanRule
  attr_reader :system_name, :switches, :limits, :rank

  def initialize(system_name:, rank:, limits: {max_services: 1, max_users: 1}, switches: [], metadata: {})
    @system_name = system_name.to_sym
    @metadata = metadata.deep_symbolize_keys
    @rank = rank
    @limits = Limit.new(limits)
    @switches = switches.map(&:to_sym)
  end

  def ==(other)
    system_name == other.system_name
  end

  def trial?
    @metadata[:trial]
  end

  def not_automatically_upgradable_to?
    @metadata[:cannot_automatically_be_upgraded_to]
  end

  def best_plan?
    PlanRulesCollection.best_plan_rule?(self)
  end

  class Limit
    def initialize(max_users:, max_services:)
      @max_users = max_users
      @max_services = max_services
    end

    attr_reader :max_users, :max_services

    def to_h
      {max_users: max_users, max_services: max_services}
    end
  end
end
