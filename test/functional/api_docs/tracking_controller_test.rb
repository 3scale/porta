require 'test_helper'

class ApiDocs::TrackingControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider)
    buyer     = FactoryBot.create(:simple_buyer, provider_account: @provider)

    host! @provider.domain

    login_as buyer.first_admin
  end

  def test_update
    get :update, format: :json

    assert_equal 200, response.status
  end
end
