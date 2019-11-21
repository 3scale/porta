# frozen_string_literal: true

class PoliciesListPresenter
  def initialize(policies)
    @policies = policies
  end

  def registry
    @policies.map do |key, value|
      policy = value.first
      policy.merge :name => key, :humanName => policy['name'], :data => {}
    end
  end
end
