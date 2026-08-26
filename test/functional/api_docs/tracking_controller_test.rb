require 'test_helper'

class ApiDocs::TrackingControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider)

    # No login needed — controller skips login_required
    host! @provider.internal_admin_domain
  end

  def test_update
    get :update, format: :json

    assert_equal 200, response.status
  end
end
