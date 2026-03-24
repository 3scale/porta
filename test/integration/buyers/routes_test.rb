require 'test_helper'

class Buyers::RoutesTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    host! @provider.internal_domain
    login_with @buyer.admins.first.username, "superSecret1234#"
  end

  test 'redirect /p/admin/dashboard to /admin' do
    get '/p/admin/dashboard'
    assert_redirected_to '/admin'
  end
end
