module BackendClient
  class Connection < Base

    DEFAULT_HOST = 'localhost:3001'

    attr_reader :host
    attr_reader :protocol

    extend ThreeScale::Benchmark

    def self.log(method, url, &block)
      title = "[BackendClient] Requesting #{method.to_s.upcase} #{url}"
      if block_given?
        benchmark(title) { yield }
      else
        logger.info(title)
      end
    end

    http_methods :get, :delete do |method, path, params|
      BackendClient::Request.new(method, url(path, params)).response
    end

    http_methods :post do |method, path, params|
      BackendClient::Request.new(method, url(path), params).response
    end

    def initialize(options = {})
      @protocol = 'http'
      @host     = options[:host] || config[:host] || DEFAULT_HOST
    end

    def provider(account)
      BackendClient::Provider.new(self, account)
    end

    def service(service)
      BackendClient::Service.new(self, service)
    end

    delegate :config, to: ::BackendClient

    private

    def url(path, params = nil)
      "#{protocol}://#{host}#{path}#{build_query_string(params)}"
    end

    def build_query_string(params)
      if params.present?
        '?' << params.to_query
      end
    end
  end
end
