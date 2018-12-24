# frozen_string_literal: true

require 'test_helper'

class Finance::Provider::LineItemsControllerTest < ActionController::TestCase

  def setup
    @provider     = FactoryBot.create(:provider_account)
    @buyer        = FactoryBot.create(:buyer_account, provider_account: @provider)
    @request.host = @provider.admin_domain
    @invoice      = FactoryBot.create(:invoice, provider_account: @provider, buyer_account: @buyer)
    @line_item    = FactoryBot.create(:line_item_plan_cost, invoice: @invoice, name: 'JohnDoe', cost: 10.0)

    login_as(@provider.admins.first)
  end

  def test_create_line_item_when_editable_invoice_html
    @invoice.update_attribute(:state, 'finalized')
    assert_difference @invoice.line_items.method(:count) do
      post :create, account_id: @buyer.id, invoice_id: @invoice.id, line_item: line_item_params
    end
    assert flash[:error].nil?
  end

  def test_not_create_line_item_when_not_editable_invoice_html
    @invoice.update_attribute(:state, 'pending')
    assert_no_difference @invoice.line_items.method(:count) do
      post :create, account_id: @buyer.id, invoice_id: @invoice.id, line_item: line_item_params
    end
    assert_match 'Invalid invoice state', flash[:error]
  end

  def test_create_line_item_when_editable_invoice_js
    @invoice.update_attribute(:state, 'finalized')
    assert_difference @invoice.line_items.method(:count) do
      post :create, account_id: @buyer.id, invoice_id: @invoice.id, line_item: line_item_params, format: 'js'
    end
    assert_template 'create'
  end

  def test_not_create_line_item_when_not_editable_invoice_js
    @invoice.update_attribute(:state, 'pending')
    assert_no_difference @invoice.line_items.method(:count) do
      post :create, account_id: @buyer.id, invoice_id: @invoice.id, line_item: line_item_params, format: 'js'
    end
    assert_template 'finance/provider/line_items/errors'
  end

  def test_create_line_item_when_editable_invoice_html
    @invoice.update_attribute(:state, 'finalized')
    assert_difference @invoice.line_items.method(:count) do
      post :create, account_id: @buyer.id, invoice_id: @invoice.id, line_item: line_item_params
    end
    assert flash[:error].nil?
  end

  def test_destroy_line_item_when_editable_invoice_html
    @invoice.update_attribute(:state, 'finalized')
    assert_difference @invoice.line_items.method(:count), -1 do
      delete :destroy, id: @line_item.id, account_id: @buyer.id, invoice_id: @invoice.id
    end
    assert flash[:error].nil?
    assert_raise(ActiveRecord::RecordNotFound) { @line_item.reload }
  end

  def test_not_destroy_line_item_when_not_editable_invoice_html
    @invoice.update_attribute(:state, 'pending')
    assert_no_difference @invoice.line_items.method(:count) do
      delete :destroy, id: @line_item.id, account_id: @buyer.id, invoice_id: @invoice.id
    end
    assert_match 'Invalid invoice state', flash[:error]
  end

  def test_destroy_line_item_when_editable_invoice_js
    @invoice.update_attribute(:state, 'finalized')
    assert_difference @invoice.line_items.method(:count), -1 do
      delete :destroy, id: @line_item.id, account_id: @buyer.id, invoice_id: @invoice.id, format: 'js'
    end
    assert_template 'destroy'
    assert_raise(ActiveRecord::RecordNotFound) { @line_item.reload }
  end

  def test_not_destroy_line_item_when_not_editable_invoice_js
    @invoice.update_attribute(:state, 'pending')
    assert_no_difference @invoice.line_items.method(:count) do
      delete :destroy, id: @line_item.id, account_id: @buyer.id, invoice_id: @invoice.id, format: 'js'
    end
    assert_template 'finance/provider/line_items/errors'
  end

  private

  def line_item_params
    { name: 'LineItemName', description: 'Description for the line item', quantity: 2, cost: 32.50 }
  end
end
