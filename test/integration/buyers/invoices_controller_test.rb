require 'test_helper'

class Buyers::InvoicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider_account, created_at: Time.zone.local(2023, 5, 4))
    @cinstance = FactoryBot.create(:cinstance, user_account: @buyer)
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
    assert_equal 'must be between the account creation date and 12 months from now', error_element.text
  end

  test 'update invoice period with a valid value' do
    @invoice = FactoryBot.create(:invoice,
                                 buyer_account: @buyer,
                                 provider_account: @provider_account)
    Invoice.any_instance.stubs(:find).returns(@invoice)

    new_period_date = Time.zone.local(2023, 7, 1)
    new_period = Month.new(new_period_date)
    put admin_buyers_account_invoice_path(@buyer, @invoice), params: { invoice: { period: new_period.to_param } }

    assert_response :redirect
    follow_redirect!
    assert_template 'buyers/invoices/show'

    page = Nokogiri::HTML::Document.parse(response.body)
    period_field = page.at("td[@id='field-period']")
    assert_equal '1 July, 2023 - 31 July, 2023', period_field.text.strip
  end

  # class MasterOnPremisesTest < ActionDispatch::IntegrationTest
end
