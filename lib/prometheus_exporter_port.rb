# frozen_string_literal: true

class PrometheusExporterPort

  PROMETHEUS_EXPORTER_DEFAULT_PORTS = {
    'multitenant' => 9394,
    'master' => 9394,
    'provider' => 9395,
    'developer' => 9396
  }.freeze

  class InvalidTenantModeError < StandardError
  end

  TENANT_MODE_CHECK = ->(mode) do
    PROMETHEUS_EXPORTER_DEFAULT_PORTS.key?(mode.to_s) ? mode.to_s : raise(InvalidTenantModeError)
  end

  def self.call
    mode = TENANT_MODE_CHECK.call(tenant_mode)
    default_port = PROMETHEUS_EXPORTER_DEFAULT_PORTS[mode]

    ENV.fetch('PROMETHEUS_EXPORTER_PORT', default_port).to_i
  end

  def self.tenant_mode
    ENV.fetch('TENANT_MODE', 'multitenant')
  end
end
