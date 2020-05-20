# frozen_string_literal: true

require 'test_helper'

class BackendDeleteServiceWorkerTest < ActiveSupport::TestCase
  test 'perform' do
    service = FactoryBot.create(:simple_service)
    event = Services::ServiceDeletedEvent.create_and_publish!(service)
    ThreeScale::Core::Service.expects(:delete_stats).with do |service_id|
      service_id == service.id
    end
    ThreeScale::Core::Service.expects(:delete_by_id!).with { |param| param == service.id.to_s }
    Sidekiq::Testing.inline! { BackendDeleteServiceWorker.enqueue(event) }
  end

  test 'perform reports error when the event does not exist' do
    System::ErrorReporting.expects(:report_error).once.with do |exception, options|
      exception.is_a?(ActiveRecord::RecordNotFound) && (parameters = options[:parameters]) && parameters[:event_id] == 'fake-id'
    end
    Sidekiq::Testing.inline! { BackendDeleteServiceWorker.perform_async('fake-id') }
  end
end
