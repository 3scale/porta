# frozen_string_literal: true

require 'test_helper'

class BackendDeleteEndUsersWorkerTest < ActiveSupport::TestCase
  test 'perform' do
    service = FactoryBot.create(:simple_service)
    event = Services::ServiceDeletedEvent.create(service)
    Rails.application.config.event_store.publish_event(event)

    ThreeScale::Core::User.expects(:delete_all_for_service).with(service.id)

    Sidekiq::Testing.inline! { BackendDeleteEndUsersWorker.perform_async(event.event_id) }
  end
end
