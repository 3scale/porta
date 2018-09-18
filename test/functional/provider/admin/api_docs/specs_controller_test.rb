require 'test_helper'

class Provider::Admin::ApiDocs::SpecsControllerTest < ActionController::TestCase

  def setup
    account = Factory.create(:provider_account)
    host! account.self_domain
    login_as(account.admins.first)
  end

  test "#show should overrite the host" do
    get :show, id: 'accounts'
    spec = JSON.parse(response.body)
    assert_equal request.host, spec["host"]
  end

  test '#show for valid ids' do
    get :show, id: 'accounts'
    assert_equal 200, response.status

    get :show, id: 'finance'
    assert_equal 200, response.status

    get :show, id: 'analytics'
    assert_equal 200, response.status

    get :show, id: 'foobar'
    assert_equal 404, response.status
  end

end
