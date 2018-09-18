require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Stats::Data::ServicesControllerTest < ActionController::TestCase

  should route(:get, '/stats/services/1/usage.json').to :service_id => '1', :action => 'usage', :format => 'json'
  should route(:get, '/stats/services/1/usage.xml').to :service_id => '1', :action => 'usage', :format => 'xml'

  should route(:get, '/stats/services/1/top_applications.json').to :service_id => '1', :action => 'top_applications', :format => 'json'
  should route(:get, '/stats/services/1/top_applications.xml').to :service_id => '1', :action => 'top_applications', :format => 'xml'



  test 'csv format for errors' do
    setup_data

    get :usage, format: :csv, service_id: @provider.default_service.id, period: 'troloro'
    assert_equal 'text/plain', response.header['Content-Type']
    assert_equal 400, response.status
  end


  private

  # Example for future tests
  def setup_data
    @provider = Factory :provider_account
    @buyer    = Factory(:buyer_account, :provider_account => @provider, timezone: 'Mountain Time (US & Canada)')
    @app_plan = Factory(:application_plan, :issuer => @provider.default_service)
    @app = @buyer.buy! @app_plan
    @request.host = @provider.admin_domain
    login_provider @provider
  end

end
