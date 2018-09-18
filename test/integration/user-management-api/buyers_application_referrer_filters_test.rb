require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::BuyersApplicationReferrerFiltersTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  include TestHelpers::FakeWeb
  include FieldsDefinitionsHelpers

  def setup
    @provider = Factory :provider_account, :domain => 'provider.example.com'
    host! @provider.admin_domain

    @buyer = Factory(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan
    @service = @provider.first_service!
    @app_plan = Factory :application_plan, :issuer => @service
    @app_plan.publish!
    @buyer.buy! @app_plan

    @buyer.reload

    ReferrerFilter.enable_backend!
  end

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryGirl.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryGirl.create(:access_token, owner: user, scopes: 'account_management')
    app   = @buyer.bought_cinstances.last

    get(admin_api_account_application_referrer_filters_path(@buyer, app))
    assert_response :forbidden
    get(admin_api_account_application_referrer_filters_path(@buyer, app), access_token: token.value)
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([app.issuer.id]).at_least_once
    get(admin_api_account_application_referrer_filters_path(@buyer, app), access_token: token.value)
    assert_response :success
  end

  #TODO: clean the tests
  test 'create referrer filters' do
    application = @buyer.bought_cinstances.last
    application_id = application.application_id
    application.service.update_attribute :referrer_filters_required, true
    referrer = 'foo.example.org'
    expect_backend_create_referrer_filter(application, referrer)

    post(admin_api_account_application_referrer_filters_path(@buyer, application, :referrer_filter => referrer, :format => :xml), :provider_key => @provider.api_key)

    assert_response :success
    assert_application(response.body, { :id => application.id, "referrer_filters/referrer_filter" => referrer })
  end

  test 'destroy referrer filters' do
    application = @buyer.bought_cinstances.last
    application_id = application.application_id
    application.service.update_attribute :referrer_filters_required, true

    referrer = "*.example.org"
    #TODO: make one of these pass, these are the real thing to test!
    # ThreeScale::Core::Application.expects(:delete_referrer_filter) #.with(rm_key).once
    expect_backend_delete_referrer_filter(application, referrer)
    expect_backend_create_referrer_filter(application, referrer)
    filter = application.referrer_filters.add(referrer)

    delete(admin_api_account_application_referrer_filter_path(@buyer.id, application.id, filter.id),
                :provider_key => @provider.api_key, :format => :xml)
    assert_response :success
  end

  test 'destroy referrer filters with referrer ending on .xml' do
    application = @buyer.bought_cinstances.last
    application_id = application.application_id
    application.service.update_attribute :referrer_filters_required, true

    referrer = "*.example.xml"
    #TODO: make one of these pass, these are the real thing to test!
    # ThreeScale::Core::Application.expects(:delete_referrer_filter) #.with(rm_key).once
    expect_backend_delete_referrer_filter(application, referrer)
    expect_backend_create_referrer_filter(application, referrer)
    filter = application.referrer_filters.add(referrer)

    # if you do it with the path helper it takes the format out of the id, which is not what RAILS does, that's why
    # test passed but it broke anyway (issue #1214)
    #delete(admin_api_account_application_referrer_filter_path(@buyer.id, application.id, referrer, :format => :xml),
    #            :provider_key => @provider.api_key, :method => "_destroy")

    delete("/admin/api/accounts/#{@buyer.id}/applications/#{application.id}/referrer_filters/#{filter.id}.xml",
              :provider_key => @provider.api_key, :format => :xml)

    assert_response :success
  end

  test 'destroy not existing referrer filter returns not found' do
    application = @buyer.bought_cinstances.last
    application_id = application.application_id
    application.service.update_attribute :referrer_filters_required, true

    # to allow . on the referrers (now that is an :id) I had to add :requirements => {:id => /.*/} in routes.rb
    referrer = "*.example.org"
    #TODO: make one of these pass, these are the real thing to test!
    # ThreeScale::Core::Application.expects(:delete_referrer_filter) #.with(rm_key).once
    expect_backend_delete_referrer_filter(application, referrer)
    expect_backend_create_referrer_filter(application, referrer)
    filter = application.referrer_filters.add(referrer)

    delete(admin_api_account_application_referrer_filter_path(@buyer.id, application.id, filter.id + 1),
                :provider_key => @provider.api_key, :format => :xml)
    assert_response :not_found

    delete(admin_api_account_application_referrer_filter_path(@buyer.id, application.id, filter.id),
                :provider_key => @provider.api_key, :format => :xml)
    assert_response :success

  end

end
