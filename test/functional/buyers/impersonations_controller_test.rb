require 'test_helper'

class Buyers::ImpersonationsControllerTest < ActionController::TestCase

  def setup
    master_account.try!(:delete)
    @provider = Factory :provider_account
  end

  test "it needs master admin" do
    login_provider @provider

    post :create, :account_id => @provider.id

    assert_response :not_found
  end

  test "should be forbidden to impersonate providers without impersonation_admin account" do
    login_provider master_account

    post :create, :account_id => @provider.id

    assert_response :forbidden
  end

  test "should impersonate a provider" do
    user = Factory :active_admin, username: ThreeScale.config.impersonation_admin['username'], :account => @provider
    @provider.reload

    login_provider master_account

    post :create, :account_id => @provider.id

    assert_response :redirect
  end

  test "api mode should return an url to impersonate a provider" do
    user = Factory :active_admin, username: ThreeScale.config.impersonation_admin['username'], :account => @provider
    @provider.reload

    login_provider master_account

    post :create, :account_id => @provider.id, :format => :json

    assert_not_nil JSON.parse(response.body)["url"]
    assert_response :created
  end
end
