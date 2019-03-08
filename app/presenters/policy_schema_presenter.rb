# frozen_string_literal: true

class PolicySchemaPresenter < SimpleDelegator
  def as_json(*)
    __getobj__.as_json(root: false, only: [:id, :schema], methods: [:directory])
  end

  class Collection < SimpleDelegator
    def as_json(*)
      __getobj__.as_json(root: false, only: [:id, :version], methods:[:summary, :humanName])
    end
  end
end
