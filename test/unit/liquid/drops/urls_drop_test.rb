require 'test_helper'

class Liquid::Drops::UrlsDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @provider = Factory(:simple_provider)
    @drop = Drops::Urls.new(@provider)
  end

  test 'payment_details' do
    @provider.update_attribute(:payment_gateway_type, 'bogus')
    assert_nil @drop.payment_details

    @provider.update_attribute(:payment_gateway_type, 'authorize_net')
    assert_equal '/admin/account/authorize_net',  @drop.payment_details.to_str
    assert_equal 'Credit Card Details', @drop.payment_details.title
  end

  test 'users' do
    assert_equal '/admin/account/users', @drop.users.to_str
    assert_equal 'Users', @drop.users.title
  end

  test 'invoices' do
    assert_equal '/admin/account/invoices', @drop.invoices.to_str
    assert_equal 'Invoices', @drop.invoices.title
  end

  test 'dashboard' do
    assert_equal '/admin', @drop.dashboard.to_str
    assert_equal 'Overview', @drop.dashboard.title
  end

  test 'access_details' do
    assert_match %r{https?://([a-z0-9.])+/admin/access_details}, @drop.access_details.to_str
    assert_equal  '', @drop.access_details.title
  end

  test 'services' do
    assert_equal '/admin/services', @drop.services.to_str
    assert_equal 'Services', @drop.services.title
  end

  test 'messages_inbox' do
    assert_match %r{^http.*/admin/messages/received$}, @drop.messages_inbox.to_str
    assert_equal 'Messages', @drop.messages_inbox.title
  end

  test '#signup' do
    assert_match %r{https?://([a-z0-9.])+/signup}, @drop.signup
  end

  test '#login' do
    assert_match %r{https?://([a-z0-9.])+/login}, @drop.login
  end

  test '#logout' do
    assert_match %r{https?://([a-z0-9.])+/logout}, @drop.logout
  end

  test '#forgot_password' do
    assert_match %r{https?://([a-z0-9.])+/admin/account/password/new}, @drop.forgot_password
  end



  test '#service_subscription' do
    assert_match %r{https?://([a-z0-9.])+/admin/service_contracts/new}, @drop.service_subscription
  end

end
