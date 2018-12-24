require 'test_helper'

class ThreeScale::DomainTest < ActiveSupport::TestCase

  def test_current_endpoint
    request_object = ActionDispatch::Request.new({})
    request_object.extend(ThreeScale::DevDomain::Request)
    request_object.stubs(:scheme).returns('http')
    request_object.stubs(:host).returns('example.net')

    assert_equal 'http://example.net', ThreeScale::Domain.current_endpoint(request_object)
    Rails.env.expects(:development?).returns(true).once
    assert_equal 'http://example.net:80', ThreeScale::Domain.current_endpoint(request_object)
    Rails.env.expects(:development?).returns(false).once
    Rails.env.expects(:preview?).returns(true).once
    assert_equal 'http://example.net', ThreeScale::Domain.current_endpoint(request_object)
  end

  def test_callback_endpoint
    parameters = { invitation_token: nil }
    account    = FactoryBot.build_stubbed(:simple_provider, domain: 'example.edu')
    endpoint   = ThreeScale::Domain.callback_endpoint(request(parameters: parameters), account)
    assert_equal 'http://example.net/auth', endpoint

    parameters[:invitation_token] = '12345'
    endpoint = ThreeScale::Domain.callback_endpoint(request(parameters: parameters), account)
    assert_equal 'http://example.net/auth/invitations/12345', endpoint

    account.stubs(:master?).returns(true)
    endpoint = ThreeScale::Domain.callback_endpoint(request(parameters: parameters), account)
    assert_equal 'http://example.edu/master/devportal/auth/invitations/12345', endpoint

    parameters[:invitation_token] = nil
    endpoint = ThreeScale::Domain.callback_endpoint(request(parameters: parameters), account)
    assert_equal 'http://example.edu/master/devportal/auth', endpoint
  end

  private

  def request(params = {})
    mock('request', { host: 'example.net', scheme: 'http' }.merge(params))
  end
end
