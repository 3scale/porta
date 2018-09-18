require 'test_helper'

class DeveloperPortal::Admin::Applications::ReferrerFiltersControllerTest < DeveloperPortal::ActionController::TestCase
  def setup
    super
    @provider  = Factory(:provider_account)
    @buyer     = Factory(:buyer_account, :provider_account => @provider)
    app_plan = Factory :application_plan, :issuer => @provider.default_service
    @cinstance = @buyer.buy! app_plan
    @referrer  = 'only.my.example.com'
  end

  test 'xhr create' do
    # stub_backend_referrer_filters
    # expect_backend_create_referrer_filter(@cinstance, @referrer)
    host! @provider.domain
    login_as(@buyer.admins.first)

    xhr :post,
        :create,
        application_id: @cinstance.to_param,
        referrer_filter: @referrer

    assert_response :success
  end

  test 'for buyers in multiple applications mode, create redirects to buyer side application page' do
    @provider.settings.allow_multiple_applications!
    @provider.settings.show_multiple_applications!

    # stub_backend_referrer_filters
    # expect_backend_create_referrer_filter(@cinstance, @referrer)

    host! @provider.domain
    login_as(@buyer.admins.first)
    post :create, application_id: @cinstance.to_param, referrer_filter: 'only.my.example.com'

    assert_redirected_to admin_application_path(@cinstance)
  end

  test 'for buyers in single applications mode, create redirects to buyer side access details page' do
    @provider.settings.deny_multiple_applications

    # stub_backend_referrer_filters
    # expect_backend_create_referrer_filter(@cinstance, @referrer)

    host! @provider.domain
    login_as(@buyer.admins.first)
    post :create, application_id: @cinstance.to_param, referrer_filter: 'only.my.example.com'

    assert_redirected_to admin_applications_access_details_path
  end
end
