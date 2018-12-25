require 'test_helper'


# FIXME: lots of changes are pending because the functionality is not
# present right now. Only on demand based change for accounts is
# implemented now
#
class DeveloperPortal::Admin::Account::AccountPlansControllerTest < DeveloperPortal::ActionController::TestCase


  test 'old api access point' do
    assert_recognizes({controller: 'developer_portal/admin/account/account_plans',
                       action: 'change',
                       format: 'xml', id: 'pro'},
                       method: :post, path: '/buyer/plans/pro/change.xml')
  end

  def setup
    super
    @provider = FactoryBot.create(:provider_account)
    @provider.settings.allow_account_plans!
    @provider.settings.show_account_plans!
    @plan = FactoryBot.create(:application_plan, :issuer => @provider.default_service)
  end

  test 'login is required' do
    @request.host = @provider.domain
    get :index
    assert_redirected_to '/login'
  end

  test 'index with only one account plan forbides access' do
    plan = FactoryBot.create(:account_plan, :issuer => @provider)
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    buyer.buy! plan

    @request.host = @provider.domain
    login_as(buyer.admins.first)
    get :index

    assert_response :forbidden
  end

  test 'index with several published account plans' do
    plan = FactoryBot.create(:account_plan, :issuer => @provider)
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    buyer.buy! plan

    plan2 = FactoryBot.create(:account_plan, :issuer => @provider)
    plan2.publish!

    @request.host = @provider.domain
    login_as(buyer.admins.first)
    get :index

    assert_response :success
  end

  test 'change via api with invalid provider_key' do
    Account.expects(:find_by_provider_key!).with('fake')
      .raises(Backend::ProviderKeyInvalid)

    @request.host = @provider.admin_domain
    post :change, :format => 'xml', :id => '42',
         :provider_key => 'fake', :username => 'bob'

    assert_response :forbidden
    assert_equal 'application/xml', @response.content_type

    assert_select 'error', 'provider_key is invalid'
  end

  test 'change via api with invalid username' do
    Account.expects(:find_by_provider_key!).with(@provider.api_key)
      .returns(@provider)

    @provider.buyer_users.expects(:find_by_username)
      .with('fake').returns(nil).at_least_once

    @request.host = @provider.admin_domain
    post :change, :format => 'xml', :id => '42',
         :provider_key => @provider.api_key,
         :username => 'fake'

    assert_response :forbidden
    assert_equal 'application/xml', @response.content_type

    assert_select 'error', 'username is invalid'
  end
end
