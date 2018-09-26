require 'test_helper'

class Buyers::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory(:provider_account)
    @plan = Factory :application_plan, :issuer => @provider.default_service

    # enabled
    feat = Factory :feature, :featurable => @provider.default_service, :name => "ticked"
    @plan.features_plans.create!(:feature => feat)

    # disabled
    Factory :feature, :featurable => @provider.default_service, :name => "crossed"

    @application = Factory(:cinstance, :plan => @plan)

    host! @provider.admin_domain
    provider_login_with @provider.admins.first.username, "supersecret"

    #TODO: dry with @ignore-backend tag on cucumber
    stub_backend_get_keys
    stub_backend_referrer_filters
    stub_backend_utilization
  end

  def test_show
    skip 'TODO - WIP - THIS TEST DOES NOT BELONG HERE ANYMORE'
    second_service = FactoryGirl.create(:simple_service, account: @provider)
    second_plan = FactoryGirl.create(:application_plan, issuer: second_service)
    second_app = FactoryGirl.create(:cinstance, plan: second_plan)

    get admin_service_application_path(@application.service, @application)
    assert_response :success
    get admin_service_application_path(second_app.service, second_app)
    assert_response :success

    User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
    get admin_service_application_path(@application.service, @application)
    assert_response :not_found
    get admin_service_application_path(second_app.service, second_app)
    assert_response :not_found

    User.any_instance.expects(:member_permission_service_ids).returns([@application.issuer.id]).at_least_once
    get admin_service_application_path(@application.service, @application)
    assert_response :success
    get admin_service_application_path(second_app.service, second_app)
    assert_response :not_found
  end

  test 'plan widget features are drawn correctly' do
    skip 'TODO - WIP - THIS TEST DOES NOT BELONG HERE ANYMORE'
    get admin_service_application_path(@application.service, @application)

    assert_response :success

    page = Nokogiri::HTML::Document.parse(response.body)
    assert page.xpath("//tr[@class='feature enabled']").text  =~ /ticked/
    assert page.xpath("//tr[@class='feature disabled']").text =~ /crossed/
  end

  test 'plan of the app does not show in the plans select' do
    skip 'TODO - WIP - THIS TEST DOES NOT BELONG HERE ANYMORE'
    @application.customize_plan! #maybe not needed, but we are checking even that custom does not appear

    get admin_service_application_path(@application.service, @application)
    assert_response :success

    page = Nokogiri::HTML::Document.parse(response.body)
    assert page.xpath("//select[@id='cinstance_plan_id']/option").map(&:text).exclude?(@application.plan.name)
  end

  test 'index shows the services column when the provider is multiservice' do
    @provider.services.create!(name: '2nd-service')
    assert @provider.reload.multiservice?
    get admin_buyers_applications_path
    page = Nokogiri::HTML::Document.parse(response.body)
    assert page.xpath("//tr").text.match /Service/
  end

  test 'index does not show the services column when the provider is not multiservice' do
    refute @provider.reload.multiservice?
    get admin_buyers_applications_path
    page = Nokogiri::HTML::Document.parse(response.body)
    refute page.xpath("//tr").text.match /Service/
  end

end
