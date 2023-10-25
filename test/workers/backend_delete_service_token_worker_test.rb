# frozen_string_literal: true

require 'test_helper'

class BackendDeleteServiceTokenWorkerTest < ActiveSupport::TestCase
  test 'destroy service token' do
    service_token = FactoryBot.create(:service_token)
    event = ServiceTokenDeletedEvent.create_and_publish!(service_token)

    Sidekiq::Testing.inline! do
      ThreeScale::Core::ServiceToken.expects(:delete).with([{ service_token: service_token.value, service_id: service_token.service_id }])
      BackendDeleteServiceTokenWorker.enqueue(event)
    end
  end
end
