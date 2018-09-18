require 'test_helper'

class Master::Api::ServicesControllerTest < ActionController::TestCase

  disable_transactional_fixtures!

  def setup
    @request.host = master_account.domain
  end

  test 'required master api_key' do
    delete :destroy, api_key: 'invalid-api-key', id: 42, provider_id: 42

    assert_response 401
    assert_equal 'unauthorized', response.body
  end

  test 'destroy a service' do
    provider  = FactoryGirl.create(:provider_account)
    buyer     = FactoryGirl.create(:simple_buyer, provider_account: provider)
    cinstance = FactoryGirl.create(:simple_cinstance, user_account: buyer)
    service   = FactoryGirl.create(:simple_service, account: provider)
    app_plan  =  FactoryGirl.create(:simple_application_plan, cinstances: [cinstance], issuer: service)

    method_event_count = RailsEventStoreActiveRecord::Event.where(event_type: %w[Services::ServiceDeletedEvent NotificationEvent]).method(:count)
    assert_difference(method_event_count, +2) do
      delete :destroy, id: service.id, provider_id: provider.id, api_key: master_account.provider_key
    end

    assert_response 200
    assert_raise(ActiveRecord::RecordNotFound) { app_plan.reload }
    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end
end
