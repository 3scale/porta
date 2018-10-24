# frozen_string_literal: true

module ServiceDiscovery
  class ClusterServiceSpecification
    OAS_CONTENT_TYPES = %w[application/swagger+json application/vnd.oai.openapi+json application/json application/text].freeze

    def self.fetch(url)
      object = new(url)
      object.fetch
      object
    end

    def initialize(url)
      @url = url
      @fetched = false
    end

    attr_reader :url, :type, :body

    def fetch!
      response = RestClient.get(url)
      @type = response.headers[:content_type]
      @body = response.body
      @fetched = true
    end

    def fetch
      fetch!
    rescue SocketError, RestClient::Exception, Errno::ECONNREFUSED, Errno::ECONNRESET => exception
      Rails.logger.error "Could not fetch API specification from #{url}: #{exception.message}"
      nil
    end

    def oas?
      OAS_CONTENT_TYPES.any?(&type.to_s.method(:starts_with?))
    end
  end
end
