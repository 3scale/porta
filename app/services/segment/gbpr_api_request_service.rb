# frozen_string_literal: true

module Segment
  module GBPRApiRequestService
    module_function

    def call(request_body:, custom_headers: {})
      return unless Features::SegmentDeletionConfig.enabled?
      connection = Faraday.new(Features::SegmentDeletionConfig.config.uri) do |faraday|
        faraday.use ResponseMiddleware
        faraday.use Faraday::Adapter::NetHttp
      end
      connection.post do |req|
        req.headers.merge!({'Content-Type' => 'application/json; charset=utf-8'}.merge(custom_headers))
        req.body = request_body
      end
    end
  end
end
