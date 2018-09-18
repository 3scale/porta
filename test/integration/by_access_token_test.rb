require 'test_helper'

class ApiAuthentication::ByAccessTokenTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_index_with_access_token
    user  = FactoryGirl.create(:member, account: @provider, admin_sections: ['partners', 'finance'])
    token = FactoryGirl.create(:access_token, owner: user, scopes: 'account_management')
    provider_2 = FactoryGirl.create(:simple_provider)

    # none token
    get(admin_api_accounts_path(format: :xml), provider_key: @provider.api_key)
    assert_response :success

    # blank token
    get(admin_api_accounts_path(format: :xml), access_token: '')
    assert_response :forbidden

    # valid token
    get(admin_api_accounts_path(format: :xml), access_token: token.value)
    assert_response :success

    # token belongs to a different admin domain
    host! provider_2.admin_domain
    get(admin_api_accounts_path(format: :xml), access_token: token.value)
    assert_response :forbidden

    host! @provider.admin_domain
    # invalid token
    get(admin_api_accounts_path(format: :xml), access_token: 'alaska')
    assert_response :forbidden

    token.scopes = ['finance']
    token.save!

    # invalid scope
    get(admin_api_accounts_path(format: :xml), access_token: token.value)
    assert_response :forbidden

    token.scopes = ['account_management']
    token.save!
    user.admin_sections = []
    user.save!

    # user does not have a permission
    get(admin_api_accounts_path(format: :xml), access_token: token.value)
    assert_response :forbidden
  end
end
