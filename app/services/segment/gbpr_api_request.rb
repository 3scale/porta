# frozen_string_literal: true

module Segment
  class GBPRApiRequest

    # This smells of :reek:FeatureEnvy (refers to 'request' more than self)
    def call(request_body:, custom_headers: {})
      connection.post do |request|
        request.headers.merge!({'Content-Type' => 'application/json; charset=utf-8'}.merge(custom_headers))
        request.body = request_body
      end
    end

    private

    # This smells of :reek:FeatureEnvy (refers to 'faraday' more than self)
    def connection
      @connection ||= Faraday.new(Features::SegmentDeletionConfig.config.uri) do |faraday|
        faraday.use ResponseMiddleware
        faraday.use Faraday::Adapter::NetHttp
      end
    end
  end
end
