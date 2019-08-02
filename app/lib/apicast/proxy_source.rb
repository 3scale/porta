require 'hashie/mash'

module Apicast
  class ProxySource
    attr_reader :proxy

    def initialize(proxy)
      @proxy = proxy
    end

    delegate :service, to: :proxy

    def reload
      @proxy.reload
      self
    end

    def to_hash
      service.as_json(Apicast::ProviderSource::SERVICE_SERIALIZE_OPTIONS.merge(root: false))
    end

    def to_json
      to_hash.to_json
    end
  end
end
