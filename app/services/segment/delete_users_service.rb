# frozen_string_literal: true

module Segment
  module DeleteUsersService
    module_function

    def call(user_ids)
      return unless Features::SegmentDeletionConfig.enabled?
      connection.post do |request|
        request.headers.merge!(request_headers)
        request.body = request_body(user_ids)
      end.body
    end

    def connection
      uri = "#{config.root_uri}/workspaces/#{config.workspace}/sources/#{config.source}/#{config.api}"
      Faraday.new(uri) do |faraday|
        faraday.use ResponseMiddleware
        faraday.use Faraday::Adapter::NetHttp
      end
    end

    def config
      Features::SegmentDeletionConfig.config
    end

    def request_body(user_ids)
      <<~JSON
        {
          \"regulation_type\": \"Suppress_With_Delete\",
          \"attributes\": {
            \"name\": \"userId\",
            \"values\": #{user_ids.map(&:to_s)}
          }
        }
      JSON
    end

    def request_headers
      {'Content-Type' => 'application/json; charset=utf-8', 'Authorization' => "Bearer #{config.token}"}
    end
  end
end
