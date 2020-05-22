# frozen_string_literal: true

class PoliciesConfigParams

  attr_reader :policies_config_params

  def initialize(policies_config_params)
    @policies_config_params = policies_config_params
  end

  def call
    return policies_config_params if json_param?

    [policies_config_params].flatten.map do |policies_config|
      policies_config.try(:permit!)
    end
  end

  private

  def json_param?
    params_class_name == 'String'
  end

  def params_class_name
    policies_config_params.class.name
  end
end