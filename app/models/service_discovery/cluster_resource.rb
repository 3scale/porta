# frozen_string_literal: true

module ServiceDiscovery
  class ClusterResource
    class InvalidResourceDefinitionError < StandardError; end

    def initialize(resource, cluster = nil)
      @resource = resource
      @cluster = cluster
    end

    attr_reader :resource, :cluster
    protected :resource, :cluster

    delegate :kind, :metadata, :spec, :status, to: :resource

    def api_version
      resource.apiVersion
    end

    def uid
      metadata[:uid]
    end

    alias id uid

    def name
      metadata[:name]
    end

    def version
      metadata[:resourceVersion]
    end

    def self_link
      metadata[:selfLink]
    end

    def created_at
      Time.zone.parse metadata[:creationTimestamp]
    end

    def labels
      @labels ||= metadata[:labels].to_h
    end

    def annotations
      @annotations ||= metadata[:annotations].to_h
    end

    def to_xml(options = {})
      properties = resource.to_h.except(:kind, :apiVersion)
      root = self.class.name.gsub(/ServiceDiscovery::Cluster/, '').downcase
      properties.to_xml(options.merge(root: root))
    end
  end
end
