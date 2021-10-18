# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlansTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'

    plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
    plan.publish!

    FactoryBot.create :account_plan,     :issuer => @provider
    FactoryBot.create :service_plan,     :issuer => @provider.default_service


    host! @provider.admin_domain
  end

  # Access token

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user    = FactoryBot.create(:member, account: @provider, admin_sections: ['partners', 'plans'])
    token   = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    service = @provider.default_service

    get(admin_api_service_application_plans_path(service))
    assert_response :forbidden
    get(admin_api_service_application_plans_path(service), params: { access_token: token.value })
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([service.id]).at_least_once
    get(admin_api_service_application_plans_path(service), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'fast track: index' do
    get admin_api_application_plans_path(:provider_key => @provider.api_key,
                                              :format => :xml)

    assert_response :success
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_only_application_plans xml
  end

  test 'security wise: index is access denied in buyer side' do
    host! @provider.domain
    get admin_api_application_plans_path(:provider_key => @provider.api_key,
                                              :format => :xml)

    assert_response :forbidden
  end

  test 'index' do
    service = FactoryBot.create :service, :account => @provider
    FactoryBot.create :application_plan, :issuer => service

    get admin_api_service_application_plans_path(service,
                                                      :provider_key => @provider.api_key,
                                                      :format => :xml)

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//plans/plan/service_id').all? { |t| t.text == service.id.to_s }

    assert_only_application_plans xml
  end

  test 'show' do
    get admin_api_service_application_plan_path(@provider.default_service,
                                                     @provider.default_service.application_plans.first,
                                                     :provider_key => @provider.api_key,
                                                     :format => :xml)

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    #TODO: move this to application_plan_test#to_xml
    assert_an_application_plan xml, @provider.default_service
  end

  test 'create' do
    post admin_api_service_application_plans_path(@provider.default_service, format: :xml), params: { :name => 'awesome application plan', :state_event => 'publish', :provider_key => @provider.api_key }

    assert_response :success


    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_application_plan xml, @provider.default_service
    assert_equal 'awesome application plan', xml.xpath('.//plan/name').children.first.to_s
    assert_equal 'published', xml.xpath('.//plan/state').children.first.to_s
  end


  test 'create without name fails' do
    post admin_api_service_application_plans_path(@provider.default_service, format: :xml), params: { :name => '', :provider_key => @provider.api_key }
    assert_equal '422', response.code
  end


  test 'update' do
    plan = FactoryBot.create :application_plan, :issuer => @provider.default_service, :name => 'namy'

    put admin_api_service_application_plan_path(@provider.default_service, plan, format: :xml), params: { :state_event => 'publish', :name => 'new name', :provider_key => @provider.api_key }

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_application_plan xml, @provider.default_service
    assert xml.xpath('.//plan/name').children.first.to_s  == 'new name'
    assert xml.xpath('.//plan/state').children.first.to_s == 'published'
    assert_equal 'false', xml.xpath('.//plan/@default').first.value
  end

  test 'default' do
    plan = FactoryBot.create :application_plan, :issuer => @provider.default_service, :name => 'namy'
    plan.publish!

    put default_admin_api_service_application_plan_path(@provider.default_service,
                                                             plan,
                                                             :provider_key => @provider.api_key,
                                                             :format => :xml)

    assert_response :ok

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_application_plan xml, @provider.default_service
    assert_equal 'true', xml.xpath('.//plan/@default').first.value
  end

  test 'destroy' do
    application_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service

    delete("/admin/api/services/#{@provider.default_service.id}/application_plans/#{application_plan.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :success
    refute @response.body.presence

    assert_raise ActiveRecord::RecordNotFound do
      application_plan.reload
    end
  end

  test 'destroy returns error when deletion failed' do
    #TODO: move this to some setup
    service = @provider.first_service!

    application_plan = FactoryBot.create :application_plan, :issuer => service
    FactoryBot.create :cinstance, :plan => application_plan

    delete("/admin/api/services/#{service.id}/application_plans/#{application_plan.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :forbidden
    assert_xml_error(@response.body, "This application plan cannot be deleted")
  end

end
