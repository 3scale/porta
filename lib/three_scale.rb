# frozen_string_literal: true

require "three_scale/private_module"
require "three_scale/domain_substitution"
require "three_scale/middleware/presigned_downloads"
require "three_scale/middleware/multitenant"
require "three_scale/middleware/cors"
require "three_scale/patterns/service"

module ThreeScale
  class ConfigurationError < StandardError; end

  ACCEPTED_TENANT_MODES = [nil, false, 'developer', 'provider', 'multitenant', 'master'].freeze

  extend self

  def config
    System::Application.config.three_scale
  end

  def tenant_mode
    config.tenant_mode.to_s.inquiry
  end

  def validate_settings!
    raise ConfigurationError, "invalid tenant_mode '#{tenant_mode}'" unless validate_settings
  end

  def validate_settings
    ACCEPTED_TENANT_MODES.include?(tenant_mode.presence)
  end

  def master_on_premises?
    ThreeScale.config.onpremises && ThreeScale.tenant_mode.master?
  end

  def master_billing_enabled?
    !ThreeScale.config.onpremises
  end

  def saas?
    !config.onpremises
  end

  extend PrivateModule
end
