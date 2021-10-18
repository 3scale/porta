# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyersServicePlansTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan

    @service_plan = FactoryBot.create :service_plan, :issuer => @provider.default_service
    @buyer.buy! @service_plan
    @buyer.reload


    host! @provider.admin_domain
  end

  test 'index' do
    get admin_api_account_service_plans_path(@buyer, :format => :xml,
                                                  :provider_key => @provider.api_key)

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert !xml.xpath('.//plans').empty?
    assert  xml.xpath('.//plans/plan/id').children.first.to_s == @service_plan.id.to_s
    assert  xml.xpath('.//plans/plan/name').children.first.to_s == @service_plan.name.to_s
    assert  xml.xpath('.//plans/plan/type').children.first.to_s == @service_plan.class.to_s.underscore

    assert  xml.xpath(".//plans/plan[@id='#{@buyer.bought_account_plan.id}']").empty?
  end

  test 'index for an inexistent account replies 404' do
    get admin_api_account_service_plans_path(0, :format => :xml), params: { :provider_key => @provider.api_key }

    assert_xml_404
  end

  test 'security wise: index is access denied in buyer side' do
    host! @provider.domain
    get admin_api_account_service_plans_path(@buyer, :format => :xml,
                                                  :provider_key => @provider.api_key)

    assert_response :forbidden
  end

  test 'buy' do
    service = FactoryBot.create(:service, account: @provider)
    service_plan = FactoryBot.create(:service_plan, :issuer => service)

    post("/admin/api/accounts/#{@buyer.id}/service_plans/#{service_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_a_service_plan xml, service
    assert xml.xpath('.//plan/id').children.first.to_s  == service_plan.id.to_s
  end

  test 'buy an already subscribed service' do
    service_plan = FactoryBot.create(:service_plan, :issuer => @provider.first_service!)

    post("/admin/api/accounts/#{@buyer.id}/service_plans/#{service_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response 422
    assert_match 'already subscribed to this service', @response.body
  end

  test 'buy a hidden plan is allowed' do
    service = FactoryBot.create(:service, account: @provider)
    service_plan = FactoryBot.create(:service_plan, :issuer => service)

    assert service_plan.hidden?
    post("/admin/api/accounts/#{@buyer.id}/service_plans/#{service_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success
  end

  test 'buy a custom plan is not allowed' do
    service = FactoryBot.create(:service, account: @provider)
    service_plan = FactoryBot.create(:service_plan, :issuer => service)
    custom_plan = service_plan.customize

    post("/admin/api/accounts/#{@buyer.id}/service_plans/#{custom_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_xml_404
  end

end
