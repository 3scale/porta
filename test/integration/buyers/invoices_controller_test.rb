require 'test_helper'

class Buyers::InvoicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @cinstance = FactoryGirl.create(:cinstance)
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
    @invoice = FactoryGirl.create(:invoice,
                                :buyer_account => @buyer,
                                :provider_account => @provider_account)
    Invoice.any_instance.stubs(:find).returns(@invoice)
    get edit_admin_buyers_account_invoice_path(@buyer, @invoice)
    assert_response :success
    assert_template 'buyers/invoices/edit'
    assert_equal @invoice, assigns(:invoice)
    assert_active_menu(:buyers)
  end

  # class MasterOnPremisesTest < ActionDispatch::IntegrationTest
end
