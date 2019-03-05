# frozen_string_literal: true

module PermittedParams
  class PolicyParams
    def initialize(parameters = {})
      @parameters = ActionController::Parameters.new.merge(parameters).permit(:name, :version)
      @parameters[:schema] = parameters[:schema]
      @parameters.permit!
    end

    def to_params
      @parameters
    end
  end
end
