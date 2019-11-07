# frozen_string_literal: true

module Segment
  class ResponseMiddleware < Faraday::Response::Middleware
    def on_complete(env)
      response = env.response
      case env.status
      when 200..299
        response
      when 500..599
        raise ServerError.new('An error occurred from the server side', response)
      when 400..499
        raise ClientError.new('An error ocurred from the client side', response)
      else
        raise UnexpectedResponseError.new('The response was unexpected', response)
      end
    end
  end
end
