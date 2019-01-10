require 'performance_helper'

class Api::SignupTest < ActionDispatch::PerformanceTest
  self.profile_options = { metrics: [:wall_time] }

  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.account_plans.default! @provider.account_plans.first

    @provider.default_service.application_plans.default! FactoryBot.create(:application_plan, :issuer => @provider.default_service)
    @provider.default_service.service_plans.default! FactoryBot.create(:service_plan, :issuer => @provider.default_service)

    host! @provider.admin_domain

    stub_backend_get_keys
  end

  def test_api_signup
    post(admin_api_signup_path, :format => :xml,
              :provider_key => @provider.api_key,
              :org_name => 'fiona',
              :username => 'fiona')
    assert_response :created
  end

  def test_account_save
    Account.transaction do
      @provider.zip = "19900"
      @provider.save!
    end
  end
end
