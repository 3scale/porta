# frozen_string_literal: true

module Segment
  module AuthenticatorService
    module_function

    def request_token(requester = GBPRApiRequest.new)
      response = requester.call(request_body: request_body)
      JSON.parse(response.body).dig('data', 'login', 'access_token')
    end

    def request_body
      {
        query: 'mutation auth($email:String!, $password:String!) {login(email:$email, password:$password)}',
        variables: Features::SegmentDeletionConfig.config.to_h.slice(:email, :password)
      }.to_json
    end
  end
end
