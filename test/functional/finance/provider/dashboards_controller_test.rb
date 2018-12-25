require 'test_helper'

class Finance::Provider::DashboardsControllerTest < ActionController::TestCase

  context 'when logged in' do
    setup do
      @provider = FactoryBot.create(:provider_account)
      @request.host = @provider.admin_domain
      login_as(@provider.admins.first)
    end

    should 'raise exception if finance switch is denied' do
      assert @provider.settings.finance.denied?
      get :show
      assert_response :forbidden
    end


    # TODO: add some fake invoices
    should 'show dashboard' do
      @provider.settings.allow_finance!
      get :show
      assert_response :success
    end
  end
end
