# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @app_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
    FactoryBot.create :feature, :featurable => @provider.default_service


    host! @provider.admin_domain
  end

  # Access token

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners', 'plans'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_application_plan_features_path(@app_plan))
    assert_response :forbidden
    get(admin_api_application_plan_features_path(@app_plan), params: { access_token: token.value })
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@provider.default_service.id]).at_least_once
    get(admin_api_application_plan_features_path(@app_plan), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'index' do
    feat = FactoryBot.create :feature, :featurable => @provider.default_service
    @app_plan.features << feat
    @app_plan.save!

    get(admin_api_application_plan_features_path(@app_plan), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)
    #OPTIMIZE: this assertions (check users_test e.g.)
    assert_all_features_of_plan xml, @app_plan
  end

  test 'not found application_plan replies 404' do
    get(admin_api_application_plan_features_path(0), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_xml_404
  end

  pending_test 'security test on buyer side domain'
  pending_test 'security test on another provider plans'

  test 'enable new feature' do
    feat = FactoryBot.create :feature, :featurable => @provider.default_service

    post(admin_api_application_plan_features_path(@app_plan), params: { :feature_id => feat.id, :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//feature/id').children.first.text == feat.id.to_s
  end

  test 'enabling feature not in service replies 404' do
    feature_not_in_service = FactoryBot.create(:feature, :featurable => @provider,
                                     :scope => "AccountPlan")

    post(admin_api_application_plan_features_path(@app_plan), params: { :feature_id => feature_not_in_service.id, :provider_key => @provider.api_key, :format => :xml })

    assert_xml_404
  end

  test 'enabling feature with wrong scope is denied' do
    wrong_feature = FactoryBot.create(:feature, :featurable => @provider.default_service,
                            :scope => "ServicePlan")

    post(admin_api_application_plan_features_path(@app_plan), params: { :feature_id => wrong_feature.id, :provider_key => @provider.api_key, :format => :xml })

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Plan type mismatch"
  end

  pending_test 'enable existing feature'

  test 'disable feature' do
    feat = FactoryBot.create :feature, :featurable => @provider.default_service

    post(admin_api_application_plan_features_path(@app_plan), params: { :feature_id => feat.id, :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//feature/id').children.first.text == feat.id.to_s
  end

  pending_test 'disable non-existing feature'

end
