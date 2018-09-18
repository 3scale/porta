require 'performance_helper'

class Api::AccountsTest < ActionDispatch::PerformanceTest
  self.profile_options = { metrics: [:wall_time] }

  def setup
    @provider = Factory(:provider_with_billing)
    @application_plan = Factory(:application_plan,
                                :issuer => @provider.default_service)
    @application_plan.publish!

    @provider.billing_strategy.update_attributes(:currency => 'EUR')

    10.times do
      buyer = Factory(:buyer_account, :provider_account => @provider)
      buyer.buy! @provider.default_account_plan
      buyer.buy! @application_plan
    end

    host! @provider.admin_domain
  end

  def test_accounts_index_xml
    5.times do
      get(admin_api_accounts_path(:format => :xml),
               :provider_key => @provider.api_key)

      assert_response :ok
    end
  end

  def test_accounts_index_json
    5.times do
      get(admin_api_accounts_path(:format => :json),
               :provider_key => @provider.api_key)

      assert_response :ok
    end
  end


end
