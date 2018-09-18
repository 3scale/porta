require 'test_helper'

class DeveloperPortal::AccessCodeTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:simple_provider)
    host! Account.master.admin_domain
  end

  def test_show
    get '/access_code?return_to=.controlled.example.com'
    assert_response :redirect
    assert_match 'http://www.example.com/', response.headers['Location']

    get '/access_code?return_to=/controlled.example.com'
    assert_response :redirect
    assert_match 'http://www.example.com/controlled.example.com', response.headers['Location']
  end

  def test_show_no_access_code
    @provider.update_attributes(site_access_code: nil)

    get '/access_code?access_code=12345'
    assert_response :redirect
    assert_match 'http://www.example.com/', response.headers['Location']
  end
end
