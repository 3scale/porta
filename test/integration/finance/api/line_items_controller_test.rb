# frozen_string_literal: true

require 'test_helper'

class Finance::Api::LineItemsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
    @provider.settings.allow_finance!
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    host! @provider.admin_domain
    @invoice = FactoryBot.create(:invoice, provider_account: @provider, buyer_account: @buyer)
    @line_item = FactoryBot.create(:line_item, invoice: @invoice, name: 'fakeName')
  end

  class MasterTest < ActionDispatch::IntegrationTest
    def setup
      @buyer = FactoryBot.create(:simple_account, provider_account: master_account)
      @invoice = FactoryBot.create(:invoice, provider_account: master_account, buyer_account: @buyer)
      @line_item = FactoryBot.create(:line_item, invoice: @invoice, name: 'fakeName')
      @token = FactoryBot.create(:access_token, owner: master_account.admin_users.first!, scopes: %w[account_management]).value
      host! master_account.admin_domain
    end

    test '#index for provider' do
      get api_invoice_line_items_path(@invoice.id), params: { access_token: @token }, session: { accept: Mime[:json] }
      assert_response :success

      ThreeScale.config.stubs(onpremises: true)
      get api_invoice_line_items_path(@invoice.id), params: { access_token: @token }, session: { accept: Mime[:json] }
      assert_response :forbidden
    end

    test '#create' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params, session: { accept: Mime[:json] }
      assert_response :success

      ThreeScale.config.stubs(onpremises: true)
      post api_invoice_line_items_path(@invoice.id), params: line_item_params, session: { accept: Mime[:json] }
      assert_response :forbidden
    end

    test '#destroy' do
      assert_difference(LineItem.method(:count), -1 ) do
        delete api_invoice_line_item_path(invoice_id: @line_item.invoice.id, id: @line_item.id), params: { access_token: @token }, session: { accept: Mime[:json] }
        assert_response :success
      end

      ThreeScale.config.stubs(onpremises: true)
      assert_no_difference LineItem.method(:count) do
        delete api_invoice_line_item_path(invoice_id: @line_item.invoice.id, id: @line_item.id), params: { access_token: @token }, session: { accept: Mime[:json] }
        assert_response :forbidden
      end
    end

    protected

    def line_item_params
      { name: 'LineItemName', description: 'Description for the line item', quantity: 2, cost: 32.50, access_token: @token }
    end
  end

  test '#index' do
    get api_invoice_line_items_path(@invoice.id), params: { access_token: @token }, session: { accept: Mime[:json] }
    assert_response :success
  end

  test '#index returns contract plan_id' do
    plan = FactoryBot.create(:simple_application_plan)
    line_item = @invoice.line_items.first
    contract = @buyer.buy! plan
    line_item.update_attribute(:contract, contract)
    get api_invoice_line_items_path(@invoice.id), params: { access_token: @token }, session: { accept: Mime::XML }

    assert_response :success
    doc = Nokogiri::XML.parse(response.body)

    assert_xpath doc, "//line_items/line-item/plan_id[text() = '#{plan.id}']"
  end

  test '#index returns plan_id' do
    @invoice.line_items.first.update_attribute(:plan_id, 2222)
    get api_invoice_line_items_path(@invoice.id), params: { access_token: @token }, session: { accept: Mime[:json] }

    assert_response :success
    json = JSON.parse(response.body)
    plan_id = json['line_items'][0]['line_item']['plan_id']
    assert_equal 2222, plan_id
  end

  test '#create with attributes saved correctly' do
    assert_difference LineItem.method(:count) do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params, session: { accept: Mime[:json] }
    end
    new_line_item = LineItem.reorder(:id).last!
    line_item_params_without_token.each do |field_name, field_value|
      assert_equal field_value, new_line_item.send(field_name)
    end
  end

  test '#create gives the right error message when the invoice doesn\'t allow to manage its line items' do
    @invoice.update_attribute(:state, 'pending')
    post api_invoice_line_items_path(@invoice.id), params: line_item_params, session: { accept: Mime[:json] }
    assert_equal ({errors: {base: ['Invalid invoice state']}}).to_json, @response.body
    assert_response 422
  end

  test 'does not raise an error if the cost cannot be converted to BigDecimal' do
    assert_difference '@invoice.line_items.count', 1 do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(cost: '$5.50'), session: { accept: Mime[:json] }
    end
    assert_response :created
    line_item = @invoice.line_items.order(:id).last!
    assert_equal ThreeScale::Money.new(0, line_item.currency), line_item.cost
  end

  test '#destroy' do
    assert_difference( LineItem.method(:count), -1 ) do
      delete api_invoice_line_item_path(invoice_id: @line_item.invoice.id, id: @line_item.id), params: { access_token: @token }, session: { accept: Mime[:json] }
      assert_response :success
    end
  end

  test '#destroy gives the right error message when the invoice doesn\'t allow to manage its line items' do
    @line_item.invoice.update_attribute(:state, 'pending')
    delete api_invoice_line_item_path(invoice_id: @line_item.invoice.id, id: @line_item.id), params: { access_token: @token }, session: { accept: Mime[:json] }
    assert_equal ({errors: {base: ['Invalid invoice state']}}).to_json, @response.body
    assert_response 403
  end

  test '#destroy gives the right error when the line item doesn\'t belong to the send invoice' do
    another_invoice = FactoryBot.create(:invoice, provider_account: @provider)
    delete api_invoice_line_item_path(invoice_id: another_invoice, id: @line_item.id), params: { access_token: @token }, session: { accept: Mime[:json] }
    assert_equal ({status: 'Not found'}).to_json, @response.body
    assert_response 404
  end

  test 'accepts adding metric_id to line_item' do
    metric = FactoryBot.create(:metric, service: @provider.services.first!)
    assert_difference '@invoice.line_items.count', 1 do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(metric_id: metric.id), session: { accept: Mime[:json] }
      @invoice.reload
      line_item = @invoice.line_items.reorder(id: :asc).last!
      assert_equal metric.id, line_item.metric_id
    end
  end

  test 'accepts adding contract_id to line_item' do
    application_plan = FactoryBot.create(:simple_application_plan, issuer: @provider.services.first!)
    contract = @buyer.buy! application_plan
    assert_difference '@invoice.line_items.count', 1 do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(contract_id: contract.id), session: { accept: Mime[:json] }
      @invoice.reload
      line_item = @invoice.line_items.reorder(id: :asc).last!
      assert_equal contract.id, line_item.contract_id
      assert_equal 'Cinstance', line_item.contract_type
    end
  end

  test 'accepts adding plan_id to line_item' do
    plan = FactoryBot.create(:simple_application_plan, issuer: @provider.services.first!)

    assert_no_difference '@invoice.line_items.count' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(plan_id: plan.id), session: { accept: Mime[:json] }
      assert_response :not_found
    end

    @buyer.buy! plan

    assert_difference '@invoice.line_items.count', 1 do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(plan_id: plan.id), session: { accept: Mime[:json] }
      @invoice.reload
      line_item = @invoice.line_items.reorder(id: :asc).last!
      assert_equal plan.id, line_item.plan_id
    end
  end

  test 'accepts adding cinstance_id to line_item' do
    plan = FactoryBot.create(:simple_application_plan, issuer: @provider.services.first!)

    cinstance = @buyer.buy! plan

    assert_difference '@invoice.line_items.count', 1 do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(cinstance_id: cinstance.id), session: { accept: Mime[:json] }
      @invoice.reload
      line_item = @invoice.line_items.reorder(id: :asc).last!
      assert_equal cinstance.id, line_item.cinstance_id
    end
  end

  test 'accepts adding type to line_item' do
    assert_difference '@invoice.line_items.count', 1 do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(type: 'LineItem::PlanCost'), session: { accept: Mime[:json] }
      @invoice.reload
      line_item = @invoice.line_items.reorder(id: :asc).last!
      assert_equal 'LineItem::PlanCost', line_item.type
    end
  end

  test 'does not accept adding metric_id to line_item' do
    metric = FactoryBot.create(:metric, service: master_account.services.first!)
    assert_no_difference '@invoice.line_items.count' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(metric_id: metric.id), session: { accept: Mime[:json] }
      assert_response :not_found
    end
  end

  test 'does not accept adding contract_id to line_item' do
    contract = @provider.contracts.first!
    assert_no_difference '@invoice.line_items.count' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(contract_id: contract.id), session: { accept: Mime[:json] }
      assert_response :not_found
    end
  end

  test 'does not accept adding plan_id to line_item' do
    plan = FactoryBot.create(:simple_application_plan, service: master_account.services.first!)
    assert_no_difference '@invoice.line_items.count' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(plan_id: plan.id), session: { accept: Mime[:json] }
      assert_response :not_found
    end
  end

  test 'does not accept adding cinstance_id to line_item' do
    plan = FactoryBot.create(:simple_application_plan, service: master_account.services.first!)
    cinstance = @provider.buy! plan

    assert_no_difference '@invoice.line_items.count' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(cinstance_id: cinstance.id), session: { accept: Mime[:json] }
      assert_response :not_found
    end
  end

  test 'does not accept adding type to line_item' do
    assert_no_difference '@invoice.line_items.count' do
      post api_invoice_line_items_path(@invoice.id), params: line_item_params.merge(type: 'Foo'), session: { accept: Mime[:json] }
    end
  end

  protected

  def line_item_params
    line_item_params_without_token.merge(access_token: @token)
  end

  def line_item_params_without_token
    { name: 'LineItemName', description: 'Description for the line item', quantity: 2, cost: 32.50 }
  end
end
