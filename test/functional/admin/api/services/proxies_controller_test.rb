require 'test_helper'

module Admin::Api::Services
  class ProxiesControllerTest < ActionController::TestCase
    def setup
      provider = FactoryGirl.create(:provider_account)
      @service = provider.default_service

      host! provider.admin_domain
      login_provider provider
    end

    def test_show
      get :show, { service_id: @service.id, format: :xml }
      assert_response :success
      xml = Hash.from_xml(@response.body).fetch('proxy').except('created_at', 'updated_at')

      get :show, service_id: @service.id, format: :json
      json = JSON.parse(@response.body).fetch('proxy').except('created_at', 'updated_at')

      assert_equal json.transform_values(&:to_s).except('links'), xml
    end

    def test_update
      post :update, { service_id: @service.id, format: :xml, proxy: {
         credentials_location: 'headers'
      } }

      assert_response :success

      proxy = @service.proxy

      assert_equal 'headers', proxy.credentials_location
    end
  end
end
