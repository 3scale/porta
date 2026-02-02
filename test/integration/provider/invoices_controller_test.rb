# frozen_string_literal: true

require 'test_helper'

class Finance::Provider::InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cinstance = FactoryBot.create(:cinstance)
    @buyer = @cinstance.buyer_account
    @provider_account = @cinstance.provider_account
    @provider_account.create_billing_strategy
    @provider_account.settings.allow_finance!

    @invoice = FactoryBot.create(:invoice, buyer_account: @cinstance.buyer_account, provider_account: @provider_account)

    @line_item = FactoryBot.create(:line_item, invoice: @invoice, cost: 2000)

    login_provider @provider_account
  end

  test 'list all invoices' do
    get admin_finance_account_invoices_path @buyer
    assert_response :success
    assert_template 'finance/provider/invoices/index'
    assert_not_nil assigns(:presenter).invoices
    assert_active_menus({main_menu: :audience, submenu: :finance, sidebar: :invoices, topmenu: :dashboard})
  end

  test 'default year when there are no invoices' do
    Invoice.where(provider_account: @provider_account).destroy_all
    @provider_account.update(timezone: 'Pacific Time (US & Canada)')

    travel_to(Time.utc(2023, 1, 1))
    get admin_finance_account_invoices_path @buyer

    assert_empty assigns(:presenter).invoices
    assert_equal [2022], assigns(:presenter).years
  end

  test 'list invoices by month' do
    get admin_finance_invoices_path @buyer, month: '2009-11'
    assert_response :success
    assert_template 'finance/provider/invoices/index'
  end

  test 'show' do
    get admin_finance_invoice_path @invoice
    assert_response :success
    assert_equal @invoice, assigns(:invoice)
    assert_active_menus({main_menu: :audience, submenu: :finance, sidebar: :invoices, topmenu: :dashboard})
  end

  test 'show without buyer_account' do
    # Invoice should be settled before destroying buyer account
    buyer = FactoryBot.create(:buyer_account)
    invoice = FactoryBot.create(:invoice, buyer_account: buyer, provider_account: @cinstance.provider_account)
    invoice.issue_and_pay_if_free!
    invoice.buyer_account.destroy!
    get admin_finance_invoice_path invoice
    assert_response :success
    assert_active_menus({main_menu: :audience, submenu: :finance, sidebar: :invoices, topmenu: :dashboard})
  end

  test 'edit' do
    get edit_admin_finance_invoice_path @invoice
    assert_response :success
    assert_equal @invoice, assigns(:invoice)
    assert_active_menus({main_menu: :audience, submenu: :finance, sidebar: :invoices, topmenu: :dashboard})
  end

  test 'update' do
    put admin_finance_invoice_path @invoice
    assert_response :redirect
    assert_equal @invoice, assigns(:invoice)
  end

  test '#charge does not invoke invoice automatic charging' do
    Invoice.any_instance.stubs('transition_allowed?').returns(true)
    Invoice.any_instance.expects(:charge!).with(false).returns(true)

    referrer = admin_finance_invoice_path(@invoice)
    put charge_admin_finance_invoice_path(@invoice), headers: { 'HTTP_REFERER' => referrer }
    assert_response :redirect
    assert_redirected_to referrer
  end

  %i[cancel pay generate_pdf charge].each do |action|
    test "#{action} action success redirects to referrer" do
      Invoice.any_instance.stubs("transition_allowed?").returns(true)
      Invoice.any_instance.stubs("#{action}!").returns(true)

      referrer = admin_finance_invoice_path(@invoice)
      put url_for([action, :admin, :finance, @invoice]), headers: { 'HTTP_REFERER' => referrer }
      assert_response :redirect
      assert_redirected_to referrer
    end

    test "#{action} action failure redirects to referrer with error" do
      Invoice.any_instance.stubs("transition_allowed?").returns(true)
      Invoice.any_instance.stubs("#{action}!").returns(false)

      referrer = admin_finance_invoice_path(@invoice)
      put url_for([action, :admin, :finance, @invoice]), headers: { 'HTTP_REFERER' => referrer }
      assert_response :redirect
      assert_redirected_to referrer
    end
  end

  test 'show with current invoice renders link to add custom line item' do
    Invoice.any_instance.stubs(:current?).returns(true)
    get admin_finance_invoice_path @invoice
    assert_response :success
  end

  test 'show with past invoice does not render link to add custom line item' do
    Invoice.any_instance.stubs(:editable?).returns(false)
    get admin_finance_invoice_path @invoice
    assert_response :success
  end

  test 'show with past invoice does not render button to delete custom line item' do
    Invoice.any_instance.stubs(:editable?).returns(false)
    get admin_finance_invoice_path @invoice
    assert_response :success
  end

  test 'show with open invoice renders button to delete custom line item' do
    Invoice.any_instance.stubs(:editable?).returns(true)
    get admin_finance_invoice_path @invoice
    assert_response :success
  end

  test 'edit with non-editable invoice redirects' do
    Invoice.any_instance.stubs(:editable?).returns(false)
    get edit_admin_finance_invoice_path(@invoice)
    assert_response :redirect
    assert_redirected_to admin_finance_invoice_path(@invoice)
  end
end
