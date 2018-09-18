require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  test 'signup javascript' do
    get '/assets/provider/signup_v2.js'

    assert_response :success
  end

end
