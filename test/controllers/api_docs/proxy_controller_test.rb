require 'test_helper'

class ApiDocs::ProxyControllerTest < ActionController::TestCase
  test 'show' do
    get :show
    assert_response :not_found
  end
end
