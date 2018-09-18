require 'test_helper'

class PaymentBuyerReferencesTest < ActiveSupport::TestCase
  class Foo
    include PaymentGateways::BuyerReferences
    attr_reader :account, :provider

    def initialize(account, provider)
      @account, @provider = account, provider
    end
  end

  test '::buyer_reference' do
    assert_equal "3scale-12345-67890", Foo.buyer_reference(account, provider)
    assert_equal "3scale-12345-67890", PaymentGateways::BuyerReferences.buyer_reference(account, provider)
  end

  test '::charge_reference' do
    assert_equal "3scale-charge-invoice-09876-67890", Foo.charge_reference(account, invoice)
    assert_equal "3scale-charge-invoice-09876-67890", PaymentGateways::BuyerReferences.charge_reference(account, invoice)
  end

  test '::recurring_authorization_reference' do
    assert_equal "3scale-recurring-authorization-12345-67890", Foo.recurring_authorization_reference(account, provider)
    assert_equal "3scale-recurring-authorization-12345-67890", PaymentGateways::BuyerReferences.recurring_authorization_reference(account, provider)
  end

  test '#buyer_reference' do
    foo = Foo.new(provider, account)
    assert_equal "3scale-67890-12345", foo.buyer_reference
  end

  test '#recurring_authorization_reference' do
    foo = Foo.new(provider, account)
    assert_equal "3scale-recurring-authorization-67890-12345", foo.recurring_authorization_reference
  end

  protected

  def provider
    @provider ||= mock.tap do |m|
      m.stubs(id: '12345')
    end
  end

  def account
    @account ||= mock.tap do |m|
      m.stubs(id: '67890')
    end
  end

  def invoice
    @invoice ||= mock.tap do |m|
      m.stubs(id: '09876')
    end
  end
end
