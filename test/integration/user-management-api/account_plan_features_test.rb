require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::AccountPlanFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @account_plan = FactoryBot.create :account_plan, :issuer => @provider
    FactoryBot.create :feature, :featurable => @provider

    host! @provider.admin_domain
  end

  test 'index' do
    feat = FactoryBot.create :feature, :featurable => @provider
    @account_plan.features << feat
    @account_plan.save!

    get(admin_api_account_plan_features_path(@account_plan.id),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_all_features_of_plan xml, @account_plan
  end

  test 'not found account_plan replies 404' do
    get(admin_api_account_plan_features_path(0),
             :provider_key => @provider.api_key, :format => :xml)
    assert_xml_404
  end

  test 'enable new feature' do
    feat = FactoryBot.create :feature, :featurable => @provider

    post(admin_api_account_plan_features_path(@account_plan.id),
              :feature_id => feat.id,
              :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//feature/id').children.first.text == feat.id.to_s
  end

  test 'enabling feature not in account replies 404' do
    feature_not_in_account = FactoryBot.create(:feature,
                                     :featurable => FactoryBot.create(:provider_account),
                                     :scope => "AccountPlan")

    post(admin_api_account_plan_features_path(@account_plan.id),
              :feature_id => feature_not_in_account.id,
              :provider_key => @provider.api_key, :format => :xml)
    assert_xml_404
  end

  pending_test 'enable existing feature'

  test 'disable feature' do
    feat = FactoryBot.create :feature, :featurable => @provider

    post(admin_api_account_plan_features_path(@account_plan.id),
              :feature_id => feat.id,
              :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert xml.xpath('.//feature/id').children.first.text == feat.id.to_s
  end

  pending_test 'disable non-existing feature'

end
