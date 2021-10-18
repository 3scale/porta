# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyersApplicationPlansTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service = @provider.services.first

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan

    @app_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
    @buyer.buy! @app_plan
    @buyer.reload

    @provider.settings.allow_multiple_applications!
    @provider.settings.show_multiple_applications!
    @service.backend_version = "1"
    @service.save!


    host! @provider.admin_domain
  end

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get admin_api_account_application_plans_path(@buyer)
    assert_response :forbidden
    get admin_api_account_application_plans_path(@buyer, access_token: token.value, format: :json)
    assert_response :success
    assert_equal 0, JSON.parse(response.body)['plans'].count
    User.any_instance.expects(:member_permission_service_ids).returns([@provider.default_service.id]).at_least_once
    get admin_api_account_application_plans_path(@buyer, access_token: token.value, format: :json)
    assert_response :success
    assert_equal 1, JSON.parse(response.body)['plans'].count
  end

  test 'index' do
    get admin_api_account_application_plans_path(@buyer, :format => :xml,
                                                  :provider_key => @provider.api_key)

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert !xml.xpath('.//plans').empty?
    assert  xml.xpath('.//plans/plan/id').children.first.to_s == @app_plan.id.to_s
    assert  xml.xpath('.//plans/plan/name').children.first.to_s == @app_plan.name.to_s
    assert  xml.xpath('.//plans/plan/type').children.first.to_s == @app_plan.class.to_s.underscore

    assert  xml.xpath(".//plans/plan[@id='#{@buyer.bought_account_plan.id}']").empty?
  end

  test 'index for an inexistent account replies 404' do
    get admin_api_account_application_plans_path(0, :format => :xml), params: { :provider_key => @provider.api_key }

    assert_xml_404
  end

  test 'security wise: index is access denied in buyer side' do
    host! @provider.domain
    get admin_api_account_application_plans_path(@buyer, :format => :xml,
                                                  :provider_key => @provider.api_key)

    assert_response :forbidden
  end

  test 'buy' do
    app_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service

    post("/admin/api/accounts/#{@buyer.id}/application_plans/#{app_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml, :name => "name", :description => "description" })

    assert_response :success
    assert @buyer.reload.bought_cinstances.detect{|c| c.plan_id == app_plan.id}

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_application_plan xml, @provider.default_service
    assert_equal app_plan.id.to_s, xml.xpath('/plan/id').children.text
  end

  test 'buy an already bought plan' do
    app_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
    app_plan.publish!

    @buyer.buy! app_plan, {:name => "name1", :description => "description1"}

    post("/admin/api/accounts/#{@buyer.id}/application_plans/#{app_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml, :name => "name2", :description => "description2" })

    assert_response :success
    assert_equal 2, @buyer.reload.bought_cinstances.select{|c| c.plan_id == app_plan.id}.size

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_application_plan(xml, @provider.default_service)
    assert_equal app_plan.id.to_s, xml.xpath('/plan/id').children.text
  end

  test 'buy a custom plan is not allowed' do
    app_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
    custom_plan = app_plan.customize

    post("/admin/api/accounts/#{@buyer.id}/application_plans/#{custom_plan.id}/buy", params: { :provider_key => @provider.api_key, :format => :xml, :name => "name", :description => "desc" })

    assert_xml_404
  end

end
