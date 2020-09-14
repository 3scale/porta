# frozen_string_literal: true

class PrometheusExporterPort

  PROMETHEUS_EXPORTER_DEFAULT_PORTS = {
    'multitenant' => 9394,
    'master' => 9394,
    'provider' => 9395,
    'developer' => 9396
  }.freeze

  class InvalidTenantModeError < StandardError
    def initialize(tenant_mode)
      @message = "TENANT_MODE #{tenant_mode.inspect} is not allowed"
    end
  end

  TENANT_MODE_CHECK = ->(mode) do
    PROMETHEUS_EXPORTER_DEFAULT_PORTS.key?(mode.to_s) ? mode.to_s : raise(InvalidTenantModeError, mode)
  end

  def self.call
    mode = TENANT_MODE_CHECK.call(tenant_mode)
    default_port = PROMETHEUS_EXPORTER_DEFAULT_PORTS[mode]

    ENV.fetch('PROMETHEUS_EXPORTER_PORT', default_port).to_i
  end

  def self.tenant_mode
    ENV['TENANT_MODE'].to_s.empty? ? 'multitenant' : ENV['TENANT_MODE']
  end
end
