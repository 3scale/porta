# frozen_string_literal: true

class PolicySchemaPresenter < SimpleDelegator
  def to_json(*)
    @policy.to_json(root: false, only: [:id, :schema], methods: [:directory])
  end

  class Collection < SimpleDelegator
    def initialize(policies)
      @policies = policies
    end

    def to_json(*)
      @policies.to_json(root: false, only: [:id, :version], methods:[:summary, :humanName])
    end
  end
end
