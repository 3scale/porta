# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest

  def setup
    @application_controller = ApplicationController.new
  end

  attr_reader :application_controller

  def test_check_browser
    provider = FactoryBot.create(:provider_account)
    login! provider

    ApplicationController.any_instance.stubs(:browser_not_modern?).returns(false)
    get admin_buyers_accounts_path
    assert_response :success
    assert flash[:error].blank?

    ApplicationController.any_instance.stubs(:browser_not_modern?).returns(true)
    get admin_buyers_accounts_path
    assert_response :redirect
    assert_match 'Please upgrade your browser and sign in again', flash[:error]
  end

  test '#save_return_to' do
    assert_equal '/foo', application_controller.send(:safe_return_to, '/foo')
    assert_equal '/foo?bar=42', application_controller.send(:safe_return_to, '/foo?bar=42')
    assert_equal '/', application_controller.send(:safe_return_to, 'http://example.com/')
    assert_equal '/?foo=bar', application_controller.send(:safe_return_to, 'http://example.com/?foo=bar')
    assert_equal '/?foo=bar&foo2=bar2', application_controller.send(:safe_return_to, 'http://example.com/?foo=bar&foo2=bar2')
  end


  test 'tracks proxy config affecting changes' do
    provider = FactoryBot.create(:provider_account)
    login! provider

    ApplicationController.any_instance.expects(:track_proxy_affecting_changes)
    ApplicationController.any_instance.expects(:flush_proxy_affecting_changes)

    get admin_buyers_accounts_path
  end
end
