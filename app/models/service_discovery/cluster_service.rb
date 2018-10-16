# frozen_string_literal: true

module ServiceDiscovery
  class ClusterService < NamespacedClusterResource
    # See https://github.com/kubernetes/kubernetes/blob/release-1.4/docs/proposals/service-discovery.md

    DISCOVERY_NAMESPACE = 'discovery.3scale.net'

    %w[scheme port path description-path].each do |field_name|
      define_method(field_name.tr('-', '_').to_sym) do
        discovery_annotation(field_name)
      end
    end

    def self.discovery_key(field_name = nil)
      [DISCOVERY_NAMESPACE, field_name].compact.join('/').to_sym
    end

    def self.discovery_label_selector
      { discovery_key => 'true' }
    end

    def host
      "#{name}.#{namespace}.svc.cluster.local"
    end

    def host_and_port
      [host, port.presence].compact.join(':')
    end

    def root
      "#{scheme}://#{host_and_port}"
    end

    def endpoint
      [root, path.to_s.sub(/^\//, '').presence].compact.join('/')
    end

    def specification_url
      description_path.to_s.starts_with?('http') ? description_path : [root, description_path.to_s.sub(/^\//, '').presence].compact.join('/')
    end

    def specification
      @specification ||= ClusterServiceSpecification.fetch(specification_url)
    end

    delegate :type, :body, :oas?, to: :specification, prefix: true
    alias oas? specification_oas?

    def valid?
      # TODO: replace that with a JSON schema
      scheme.present? && port.presence.to_s =~ /\A(\d)+\Z/
    end

    def discoverable?
      discovery_label.to_s == 'true' && valid?
    end

    protected

    def discovery_label(field_name = nil)
      labels[self.class.discovery_key(field_name)]
    end

    def discovery_annotation(field_name = nil)
      annotations[self.class.discovery_key(field_name)]
    end
  end
end
