require 'test_helper'

class Provider::Admin::ReferrerFiltersControllerTest < ActionController::TestCase

  def setup
    super
    @provider  = FactoryBot.create(:provider_account)
    @buyer     = FactoryBot.create(:buyer_account, :provider_account => @provider)
    app_plan   = FactoryBot.create :application_plan, :issuer => @provider.default_service
    @cinstance = @buyer.buy! app_plan
    @referrer  = 'example.com'

    # stub_backend_referrer_filters
    # expect_backend_create_referrer_filter(@cinstance, @referrer)
    host! @provider.self_domain
    login_as(@provider.admins.first)
  end

  test 'create' do
    xhr :post,
        :create,
        application_id: @cinstance.to_param,
        referrer_filter: @referrer

    assert_response :success
  end

  # regression test for https://3scale.airbrake.io/projects/14982/groups/71566877/notices/1105888258832983894
  test 'create with error' do
    ReferrerFilter.any_instance.stubs(persisted?: false)

    xhr :post,
        :create,
        application_id: @cinstance.to_param,
        referrer_filter: @referrer

    assert_response :success
  end

end
