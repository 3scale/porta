# frozen_string_literal: true

require 'test_helper'

class BackendDeleteServiceWorkerTest < ActiveSupport::TestCase
  test 'perform' do
    service = FactoryBot.create(:simple_service)
    event = Services::ServiceDeletedEvent.create(service)
    Rails.application.config.event_store.publish_event(event)

    BackendDeleteEndUsersWorker.expects(:perform_async).with { |param| param == event.event_id }
    BackendDeleteStatsWorker.expects(:perform_async).with { |param| param == event.event_id }
    Sidekiq::Testing.inline! { BackendDeleteServiceWorker.enqueue(event) }
  end

  test 'on_success' do
    service_id = (Service.last&.id || 0) + 1
    ThreeScale::Core::Service.expects(:delete_by_id!).with { |param| param == service_id.to_s }
    BackendDeleteServiceWorker.new.on_success(1, {'service_id' => service_id})
  end
end
