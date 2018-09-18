require 'test_helper'

class Stats::Data::ApplicationsControllerTest < ActionController::TestCase

  should route(:get, '/stats/applications/42/usage.json').to :application_id => '42', :action => 'usage', :format => 'json'

  def test_summary
    setup_data(login_as: :buyer)

    get :summary, format: :json, application_id: @app.id

    assert_equal 200, response.status
  end

  test 'csv format for errors' do
    setup_data

    get :usage, format: :csv, application_id: @app.id, period: 'troloro'
    assert_equal 'text/plain', response.header['Content-Type']
    assert_equal 400, response.status

    get :usage_response_code, format: :csv, application_id: @app.id, period: 'troloro'
    assert_equal 'text/plain', response.header['Content-Type']
    assert_equal 400, response.status
  end

  private

  # setup_data instead of setup because "should route" run "setup" each time
  def setup_data(login_as: :provider)
    @provider = FactoryGirl.create(:provider_account)
    @buyer    = FactoryGirl.create(:buyer_account, provider_account: @provider, timezone: 'Mountain Time (US & Canada)')
    @app_plan = FactoryGirl.create(:application_plan, issuer: @provider.default_service)
    @app      = @buyer.buy! @app_plan

    @request.host = @provider.admin_domain

    case login_as
    when :provider
      login_provider @provider
    when :buyer
      login_buyer @buyer
    end
  end
end
