# frozen_string_literal: true

require 'test_helper'

class BackendDeleteEndUsersWorkerTest < ActiveSupport::TestCase
  def setup
    @service = FactoryBot.create(:simple_service)
    @event = Services::ServiceDeletedEvent.create(service)
    Rails.application.config.event_store.publish_event(event)
  end

  attr_reader :service, :event

  test 'perform' do
    ThreeScale::Core::User.expects(:delete_all_for_service).with(service.id)

    Sidekiq::Testing.inline! { BackendDeleteEndUsersWorker.perform_async(event.event_id) }
  end

  test 'perform reports error when the event does not exist' do
    System::ErrorReporting.expects(:report_error).once.with do |exception, options|
      exception.is_a?(ActiveRecord::RecordNotFound) && (parameters = options[:parameters]) && parameters[:event_id] == 'fake-id'
    end
    Sidekiq::Testing.inline! { BackendDeleteEndUsersWorker.perform_async('fake-id') }
  end

  test 'perform reports error when the service does not exist in backend' do
    error = ThreeScale::Core::APIClient::APIError.new('method', 'uri', OpenStruct.new({status: 400, body: 'error message'}), {})
    ThreeScale::Core::User.expects(:delete_all_for_service).with(service.id).raises(error)

    System::ErrorReporting.expects(:report_error).once.with do |exception, options|
      exception.is_a?(ThreeScale::Core::APIClient::APIError) && \
        (parameters = options[:parameters]) && parameters[:event_id] == event.event_id && parameters[:service_id] == service.id
    end
    Sidekiq::Testing.inline! { BackendDeleteEndUsersWorker.perform_async(event.event_id) }
  end
end
