require 'test_helper'

class Finance::Api::InvoicesControllerTest < ActionDispatch::IntegrationTest
  module InvoiceHelpers
    protected

    def invoice
      @invoice ||= FactoryBot.create(:invoice, provider_account: @provider,
                                     buyer_account: @buyer,
                                     period: Month.parse_month('2018-08-01')).reload
    end

    def invoice_params
      { account_id: @buyer.id, period: invoice_new_values[:month].to_param, friendly_id: invoice_new_values[:friendly_id], access_token: @access_token }
    end

    def invoice_new_values
      month = Month.new('2017', '07')
      { month: month, friendly_id: "#{month.to_param}-00000005" }
    end
  end

  include InvoiceHelpers

  class MasterOnPremisesTest < ActionDispatch::IntegrationTest
    include InvoiceHelpers

    def setup
      ThreeScale.config.stubs(onpremises: true)
      @access_token = FactoryBot.create(:access_token, owner: master_account.admin_users.first!, scopes: %w[finance]).value
      @provider = master_account
      @buyer = FactoryBot.create(:simple_provider)
      master_account.settings.allow_finance!
      host! master_account.admin_domain
      %w[2017-07 2018-08].each { |month| FactoryBot.create(:invoice_counter, provider_account: @provider, invoice_prefix: month) }
    end

    test '#index' do
      get api_invoices_path, headers: { accept: Mime[:json] }, params: { access_token: @access_token }
      assert_response :forbidden
    end

    test '#show' do
      get api_invoice_path(invoice), headers: { accept: Mime[:json] }, params: { access_token: @access_token }
      assert_response :forbidden
    end

    test '#state' do
      put state_api_invoice_path(invoice, state: 'cancelled'), headers: { accept: Mime[:json] }, params: { access_token: @access_token }
      assert_response :forbidden
    end

    test '#create' do
      post api_invoices_path, headers: { accept: Mime[:json] }, params: { access_token: @access_token }.merge(invoice_params)
      assert_response :forbidden
    end
  end

  disable_transactional_fixtures!

  def setup
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @provider.settings.allow_finance!
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[finance]).value
    host! @provider.admin_domain

    %w[2017-07 2018-08].each { |month| FactoryBot.create(:invoice_counter, provider_account: @provider, invoice_prefix: month) }
  end

  test '#index' do
    get api_invoices_path, params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    assert_response :success
  end

  test '#show' do
    get api_invoice_path(invoice), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    assert_response :success
  end

  test '#state' do
    put state_api_invoice_path(invoice, state: 'cancelled'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'cancelled', invoice.state
  end

  test '#state fail state' do
    invoice.state = :unpaid
    invoice.save!
    put state_api_invoice_path(invoice, state: 'failed'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'failed', invoice.state
  end

  test '#state mark_as_unpaid state' do
    invoice.state = :pending
    invoice.save!
    put state_api_invoice_path(invoice, state: 'unpaid'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'unpaid', invoice.state
  end

  test '#state pay state' do
    invoice.fire_events!(:issue)
    put state_api_invoice_path(invoice, state: 'paid'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'paid', invoice.state
  end

  test '#state issue state' do
    put state_api_invoice_path(invoice, state: 'pending'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'pending', invoice.state
  end

  test '#wrong transition state' do
    invoice.state = :paid
    invoice.save!
    put state_api_invoice_path(invoice, state: 'pending'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'paid', invoice.state
    assert_response 422
  end

  test '#state inalize state' do
    put state_api_invoice_path(invoice, state: 'finalized'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal 'finalized', invoice.state
  end

  test '#state incorrect state' do
    put state_api_invoice_path(invoice, state: 'wrong_state'), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    assert_equal '{"errors":{"base":["Cannot transition to wrong_state"]}}', response.body
    assert_response 422
  end

  test '#create' do
    post api_invoices_path, params: invoice_params, headers: { accept: Mime[:json] }
    assert_response :success
  end

  test '#create with attributes saved correctly' do
    assert_difference Invoice.method(:count) do
      post api_invoices_path, params: invoice_params, headers: { accept: Mime[:json] }
    end
    assert_equal invoice_new_values[:month], Invoice.find_by(provider_account_id: @provider.id, buyer_account_id: @buyer.id).period
  end

  test '#create with invalid period' do
    post api_invoices_path, params: invoice_params.merge(period: 'abc'), headers: { accept: Mime[:json] }
    assert_response 422
    assert_contains JSON.parse(response.body)['errors']['period'], 'Billing period format should be YYYY-MM'
  end

  test '#update states' do
    put api_invoice_path(invoice), params: invoice_params, headers: { accept: Mime[:json] }
    assert_response :success
  end

  test '#update with attributes saved correctly' do
    put api_invoice_path(invoice), params: invoice_params, headers: { accept: Mime[:json] }
    invoice.reload
    assert_equal invoice_new_values[:month], invoice.period
    assert_equal invoice_new_values[:friendly_id], invoice.friendly_id
  end

  test 'audit the invoice with the user when the authentication is by access token' do
    admin = @provider.admin_users.first!
    token = FactoryBot.create(:access_token, owner: admin, scopes: %w[finance])

    assert_difference(Audited.audit_class.method(:count)) do
      Invoice.with_synchronous_auditing do
        assert_difference(Invoice.method(:count)) do
          post api_invoices_path, params: invoice_params.merge!(access_token: token.value), headers: { accept: Mime[:json] }
          assert_response :created
        end
      end
    end

    audit = Audited.audit_class.last!
    assert_equal 'Invoice', audit.auditable_type
    assert_equal Invoice.last!.id, audit.auditable_id
    assert_equal admin.id, audit.user_id
  end

  test '#charge' do
    post charge_api_invoice_path(invoice), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    assert_response 422
    assert_contains JSON.parse(response.body)['errors']['state'], invoice.errors.generate_message(:state, :not_in_chargeable_state, id: invoice.id)

    invoice.line_items << LineItem.new(:cost => 100)

    invoice.fire_events! :issue

    # Heavy/ugly mocking on buyer charge!
    Account.any_instance.expects(:charge!).returns(true)

    post charge_api_invoice_path(invoice), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    assert_equal invoice.reload.state, 'paid'
    assert_response :success

    Account.any_instance.expects(:charge!).returns(false)
    invoice.state = :pending
    invoice.save!
    post charge_api_invoice_path(invoice), params: { access_token: @access_token }, headers: { accept: Mime[:json] }
    assert_response 422
    assert_contains JSON.parse(response.body)['errors']['base'], invoice.errors.generate_message(:base, :charging_failed)
  end
end
