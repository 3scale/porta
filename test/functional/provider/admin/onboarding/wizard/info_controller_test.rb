require 'test_helper'

class Provider::Admin::Onboarding::Wizard::InfoControllerTest < ActionController::TestCase

  def setup
    login_provider master_account
  end

  def test_index
    get :index
    assert_redirected_to action: :intro
  end

  def test_intro
    get :intro
    assert_response :success
  end

  def test_explain
    get :explain
    assert_response :success
  end

  def test_outro
    get :outro
    assert_response :success
  end
end
