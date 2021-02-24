# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Account::InvoicesControllerTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  setup do
    @provider = FactoryBot.create(:provider_account, payment_gateway_type: :stripe, payment_gateway_options: { login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx' })
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)

    provider_settings.allow_finance!
    provider_settings.show_finance!

    @invoice = FactoryBot.create(:invoice, buyer_account: buyer, provider_account: provider)
    invoice.issue

    login_buyer buyer
  end

  attr_reader :provider, :invoice
  delegate :settings, to: :provider, prefix: true

  test 'access is denied if finance is not visible' do
    provider_settings.hide_finance!
    provider_settings.deny_finance!

    refute provider.settings.finance.visible?
    get admin_account_invoices_path
    assert_response :forbidden
  end

  test 'payment' do
    payment_intent = create_payment_intent
    stripe_payment_intent = mock(client_secret: 'some-client-secret')
    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent.reference, any_parameters).returns(stripe_payment_intent)
    get payment_admin_account_invoice_path(invoice)
    assert_response :ok
    assert_equal 'some-client-secret', assigns(:client_secret)
  end

  test 'payment_succeeded updates the invoice' do
    payment_intent = create_payment_intent
    stripe_payment_intent = mock
    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent.reference, any_parameters).returns(stripe_payment_intent)
    Finance::StripePaymentIntentUpdateService.expects(:new).with(provider, stripe_payment_intent).returns(mock(call: true))
    post payment_succeeded_admin_account_invoice_path(invoice, params: payment_succeeded_params)
    assert_response :redirect
    assert_equal 'Payment transaction updated', flash[:notice]
  end

  test 'payment_succeeded with no-op payment intent status' do
    payment_intent = create_payment_intent
    stripe_payment_intent = mock
    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent.reference, any_parameters).returns(stripe_payment_intent)
    Finance::StripePaymentIntentUpdateService.expects(:new).with(provider, stripe_payment_intent).returns(mock(call: false))
    post payment_succeeded_admin_account_invoice_path(invoice, params: payment_succeeded_params)
    assert_response :redirect
    assert_equal 'Failed to update payment transaction', flash[:error]
  end

  test 'payment while missing pending payment intent' do
    get payment_admin_account_invoice_path(invoice)
    assert_response :not_found
  end

  test 'payment_succeeded missing params' do
    post payment_succeeded_admin_account_invoice_path(invoice)
    assert_response :bad_request
  end

  test 'payment_succeeded missing payment intent' do
    post payment_succeeded_admin_account_invoice_path(invoice, params: payment_succeeded_params)
    assert_response :not_found
  end

  test 'unsupported payment gateway' do
    provider.payment_gateway_type = :bogus
    provider.save!
    get payment_admin_account_invoice_path(invoice)
    assert_response :not_found
  end

  protected

  def create_payment_intent(invoice: self.invoice, reference: 'some-payment-intent-id')
    FactoryBot.create(:payment_intent, invoice: invoice, reference: reference)
  end

  def payment_succeeded_params(payment_intent_id: 'some-payment-intent-id')
    { payment_intent: { id: payment_intent_id } }
  end
end
