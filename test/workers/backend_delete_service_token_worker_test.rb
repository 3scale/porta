# frozen_string_literal: true

require 'test_helper'

class BackendDeleteServiceTokenWorkerTest < ActiveSupport::TestCase

  def teardown
    clear_sidekiq_lock
  end

  test 'destroy service token' do
    service_token = FactoryGirl.create(:service_token)
    event = ServiceTokenDeletedEvent.create(service_token)
    Rails.application.config.event_store.publish_event(event)

    Sidekiq::Testing.inline! do
      ThreeScale::Core::ServiceToken.expects(:delete).with([{ service_token: service_token.value, service_id: service_token.service_id }])
      BackendDeleteServiceTokenWorker.enqueue(event)
    end
  end
end
