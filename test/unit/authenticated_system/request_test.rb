# frozen_string_literal: true

require 'test_helper'
class AuthenticatedSystem::RequestTest < ActiveSupport::TestCase
  setup do
    ThreeScale.config.stubs(:zync_authentication_token).returns('correct-token')
  end

  test '#zync? returns true when the request token is the one of Zync' do
    assert authenticated_system_request('correct-token').zync?
  end

  test '#zync? returns false when the request token is not the of Zync' do
    refute authenticated_system_request('fake-token').zync?
  end

  test '#zync? returns false if there is no Zync token defined' do
    ThreeScale.config.stubs(:zync_authentication_token).returns('')
    refute authenticated_system_request('').zync?
  end

  private

  def authenticated_system_request(zync_token)
    AuthenticatedSystem::Request.new DummyHttpRequest.new(zync_token)
  end

  class DummyHttpRequest
    def initialize(zync_token)
      @headers = {'X-Zync-Token' => zync_token}
    end
    attr_reader :headers
  end
end
