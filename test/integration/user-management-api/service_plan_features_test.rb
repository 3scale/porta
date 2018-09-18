require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class EnterpriseApiServicePlanFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory :provider_account, :domain => 'provider.example.com'
    @service_plan = Factory :service_plan, :issuer => @provider.default_service
    Factory :feature, :featurable => @provider.default_service, :scope => "ServicePlan"


    host! @provider.admin_domain
  end

  test 'index' do
    feat = Factory(:feature, :featurable => @provider.default_service,
                   :scope => "ServicePlan")
    @service_plan.features << feat
    @service_plan.save!

    get(admin_api_service_plan_features_path(@service_plan),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_all_features_of_plan xml, @service_plan
  end

  test 'not found service_plan replies 404' do
    get(admin_api_service_plan_features_path(0),
             :provider_key => @provider.api_key, :format => :xml)
    assert_xml_404
  end

  pending_test 'security test on buyer side domain'
  pending_test 'security test on another provider plans' #???

  test 'enable new feature' do
    feat = Factory(:feature, :featurable => @provider.default_service,
                   :scope => "ServicePlan")

    post(admin_api_service_plan_features_path(@service_plan),
              :feature_id => feat.id,
              :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//feature/id').children.first.text == feat.id.to_s
  end

  test 'enabling feature not in service replies 404' do
    feature_not_in_service = Factory(:feature, :featurable => @provider,
                                     :scope => "AccountPlan")

    post(admin_api_service_plan_features_path(@service_plan),
              :feature_id => feature_not_in_service.id,
              :provider_key => @provider.api_key, :format => :xml)
    assert_xml_404
  end

  test 'enabling feature with wrong scope is denied' do
    wrong_feature = Factory(:feature, :featurable => @provider.default_service,
                            :scope => "ApplicationPlan")

    post(admin_api_service_plan_features_path(@service_plan),
              :feature_id => wrong_feature.id,
              :provider_key => @provider.api_key, :format => :xml)

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Plan type mismatch"
  end

  pending_test 'enable existing feature'

  test 'disable feature' do
    feat = Factory(:feature, :featurable => @provider.default_service,
                   :scope => "ServicePlan")

    post(admin_api_service_plan_features_path(@service_plan),
              :feature_id => feat.id,
              :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//feature/id').children.first.text == feat.id.to_s
  end

  pending_test 'disable non-existing feature'

end
