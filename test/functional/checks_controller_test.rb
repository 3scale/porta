require 'test_helper'

class ChecksControllerTest < ActionController::TestCase

  test 'on show' do
    get :check
    assert_response :ok
    assert_equal 'ok', @response.body
  end

  test 'head' do
    head :check
    assert_response :ok
  end
end
