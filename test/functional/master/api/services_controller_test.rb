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
    provider  = FactoryBot.create(:provider_account)
    buyer     = FactoryBot.create(:simple_buyer, provider_account: provider)
    cinstance = FactoryBot.create(:simple_cinstance, user_account: buyer)
    service   = FactoryBot.create(:simple_service, account: provider)
    app_plan  =  FactoryBot.create(:simple_application_plan, cinstances: [cinstance], issuer: service)

    method_service_deleted_event_count = RailsEventStoreActiveRecord::Event.where(event_type: Services::ServiceDeletedEvent).method(:count)
    method_notification_event_count    = RailsEventStoreActiveRecord::Event.where(event_type: NotificationEvent).method(:count)
    assert_difference(method_notification_event_count, +1) do
      assert_difference(method_service_deleted_event_count, +1) do
        delete :destroy, id: service.id, provider_id: provider.id, api_key: master_account.provider_key
      end
    end

    assert_response 200
    assert_raise(ActiveRecord::RecordNotFound) { app_plan.reload }
    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end
end
