require 'test_helper'

class Provider::Admin::ApiDocs::SpecsControllerTest < ActionController::TestCase

  def setup
    account = FactoryBot.create(:provider_account)
    host! account.internal_admin_domain
    login_as(account.admins.first)
  end

  test "#show should overrite the host" do
    get :show, params: { id: 'accounts' }

    spec = JSON.parse(response.body)
    assert_equal request.host, spec["host"]
  end

  test '#show for valid ids' do
    get :show, params: { id: 'accounts' }
    assert_equal 200, response.status

    get :show, params: { id: 'finance' }
    assert_equal 200, response.status

    get :show, params: { id: 'analytics' }
    assert_equal 200, response.status

    get :show, params: { id: 'foobar' }
    assert_equal 404, response.status
  end

end
