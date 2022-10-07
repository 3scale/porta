require 'test_helper'

class Buyers::InvoicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @cinstance = FactoryBot.create(:cinstance)
    @buyer = @cinstance.buyer_account
    @provider_account = @cinstance.provider_account
    @provider_account.create_billing_strategy
    @provider_account.settings.allow_finance!

    @provider_account.settings.allow_finance
    login! @provider_account
  end

  test 'list all invoices for a buyer' do
    get admin_buyers_account_invoices_path(@buyer)
    assert_response :success
    assert_template 'buyers/invoices/index'
    assert_not_nil assigns(:invoices)
    assert_active_menu(:buyers)
  end

  test 'create a new invoice for a buyer' do
    assert_difference ->{ Invoice.count }, 1 do
      post admin_buyers_account_invoices_path(@buyer)
      assert_response :redirect
      invoice = @buyer.invoices.last!
      assert_equal 'manual', invoice.creation_type
    end
    assert_active_menu(:buyers)
  end

  test 'edit existing invoice header' do
    @invoice = FactoryBot.create(:invoice,
                                :buyer_account => @buyer,
                                :provider_account => @provider_account)
    Invoice.any_instance.stubs(:find).returns(@invoice)
    get edit_admin_buyers_account_invoice_path(@buyer, @invoice)
    assert_response :success
    assert_template 'buyers/invoices/edit'
    assert_equal @invoice, assigns(:invoice)
    assert_active_menu(:buyers)
  end

  test 'do not update invoice if year is invalid' do
    @invoice = FactoryBot.create(:invoice,
                                 :buyer_account => @buyer,
                                 :provider_account => @provider_account)
    Invoice.any_instance.stubs(:find).returns(@invoice)

    period = '0008-12'
    put admin_buyers_account_invoice_path(@buyer, @invoice), params: { invoice: { period: period } }

    assert_response :success
    assert_template 'buyers/invoices/edit'

    page = Nokogiri::HTML::Document.parse(response.body)
    period_input = page.at("input[@id='invoice_period']")
    assert_equal period, period_input['value']
    error_element = period_input.next_element
    assert_equal 'inline-errors', error_element['class']
    assert_equal 'Year must be between 1980 and 2100', error_element.text
  end

  # class MasterOnPremisesTest < ActionDispatch::IntegrationTest
end
