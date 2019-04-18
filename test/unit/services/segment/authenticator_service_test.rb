# frozen_string_literal: true

require 'test_helper'

class Segment::AuthenticatorServiceTest < ActiveSupport::TestCase
  def setup
    @config = {'enabled' => true, 'email' => 'email@example.com', 'password' => 'example-password', 'uri' => 'https://gdpr.example.com/graphql', 'workspace' => 'workspace'}
    Features::SegmentDeletionConfig.configure(config)
  end

  attr_reader :config

  class RightResponseTest < Segment::AuthenticatorServiceTest
    test '#request_token returns the token from segment' do
      request = token_request(status: 200, token: 'example-token')

      assert_equal 'example-token', Segment::AuthenticatorService.request_token
      assert_requested request
    end
  end

  class WrongResponseTest < Segment::AuthenticatorServiceTest
    test 'server error' do
      token_request(status: 500)
      assert_raise(::Segment::ServerError) { Segment::AuthenticatorService.request_token }
    end

    test 'client error' do
      token_request(status: 400)
      assert_raise(::Segment::ClientError) { Segment::AuthenticatorService.request_token }
    end

    test 'any other status' do
      token_request(status: 300)
      assert_raise(::Segment::UnexpectedResponseError) { Segment::AuthenticatorService.request_token }
    end
  end

  private

  def token_request(status:, token: 'token')
    response_body = status == 200 ? "{\"data\":{\"login\":{\"access_token\":\"#{token}\"}}}" : 'error response'
    stub_request(:post, config['uri']).
      with(body: "{\"query\":\"mutation auth($email:String!, $password:String!) {login(email:$email, password:$password)}\",\"variables\":{\"email\":\"#{config['email']}\",\"password\":\"#{config['password']}\"}}",
           headers: {'Content-Type'=>'application/json; charset=utf-8'}).
      to_return(status: status, body: response_body)
  end
end
