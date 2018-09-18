module BackendClient
  class Request
    include ThreeScale::Benchmark

    attr_reader :http_method, :url, :params

    def initialize(method, url, params = nil)
      @http_method, @url, @params = method, url, params
    end

    def response
      with_retries do
        RestClient::Request.execute(options)
      end
    rescue => exception
      # this exception is going to be catched by:
      # https://github.com/rails/rails/blob/83e42d52e37a33682fcac856330fd5d06e5a529c/activerecord/lib/active_record/connection_adapters/abstract/database_statements.rb#L371-L375
      # thats why we need to fire an airbrake
      logger.error { exception }
      System::ErrorReporting.report_error(exception, parameters: { method: http_method, url: url, params: params})
      raise(exception)
    end

    def try(&block)
      title = "[BackendClient] Requesting #{http_method.to_s.upcase} #{url}"
      result = benchmark(title) { yield }
    end

    def failure(exception, attempt)
      logger.error "[BackendClient] Request #{self} failed with #{exception} (#{attempt}/#{max_tries})"
    end

    def to_s
      "BackendClient::Request(method: #{http_method}, url: #{url}, params: #{params})"
    end

    def max_tries
      BackendClient.config[:max_tries]
    end

    def options
      default_options.merge(method: http_method, url: url, payload: params)
    end

    def default_options
      BackendClient.config.reverse_merge(timeout: 3, open_timeout: 3)
    end

    def with_retries(&block)
      max_tries.times do |n|
        attempt = n + 1
        begin
          return try { yield(attempt) }
        rescue
          failure($!, attempt)
          raise if attempt == max_tries
        end
      end
    end
  end
end
