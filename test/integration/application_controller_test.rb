# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @application_controller = ApplicationController.new
  end
  
  attr_reader :application_controller

  test '#save_return_to' do
    assert_equal '/foo', application_controller.send(:safe_return_to, '/foo')
    assert_equal '/foo?bar=42', application_controller.send(:safe_return_to, '/foo?bar=42')
    assert_equal '/', application_controller.send(:safe_return_to, 'http://example.com/')
    assert_equal '/?foo=bar', application_controller.send(:safe_return_to, 'http://example.com/?foo=bar')
    assert_equal '/?foo=bar&foo2=bar2', application_controller.send(:safe_return_to, 'http://example.com/?foo=bar&foo2=bar2')
  end

  test '#target_host' do
    provider = Account.new
    provider.stubs(:admin_domain).returns('provider-admin.3scale.net')
    request_object = ActionDispatch::Request.new({})

    # Development environment
    request_object.stubs(:raw_host_with_port).returns("master-admin.#{ThreeScale.config.dev_gtld}:3000")
    application_controller.stubs(:request).returns(request_object)
    assert_equal "provider-admin.3scale.net.#{ThreeScale.config.dev_gtld}:3000", application_controller.send(:target_host, provider)

    # Production environment
    ThreeScale.config.stubs(dev_gtld: nil)
    request_object.stubs(:raw_host_with_port).returns('master-admin.3scale.net')
    application_controller.stubs(:request).returns(request_object)
    assert_equal 'provider-admin.3scale.net', application_controller.send(:target_host, provider)
  end
end
