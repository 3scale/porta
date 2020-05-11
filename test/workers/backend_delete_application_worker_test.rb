# frozen_string_literal: true

require 'test_helper'

class BackendDeleteApplicationWorkerTest < ActiveSupport::TestCase
  test 'perform' do
    application = FactoryBot.create(:simple_cinstance, application_id: 'backend-app-id')
    service = application.service

    seq = sequence('destroy sequence')
    ApplicationKeyBackendService.expects(:delete_all).with(application_id: application.id, service_backend_id: service.backend_id, application_backend_id: application.application_id).in_sequence(seq)
    ReferrerFilterBackendService.expects(:delete_all).with(application_id: application.id, service_backend_id: service.backend_id, application_backend_id: application.application_id).in_sequence(seq)
    ThreeScale::Core::Application.expects(:delete).with(service.backend_id, application.application_id).in_sequence(seq)

    event = Applications::ApplicationDeletedEvent.create_and_publish!(application)
    Sidekiq::Testing.inline! { BackendDeleteApplicationWorker.perform_later(event.event_id) }
  end

  test 'perform reports error when the event does not exist' do
    System::ErrorReporting.expects(:report_error).once.with do |exception, options|
      exception.is_a?(ActiveRecord::RecordNotFound) && (parameters = options[:parameters]) && parameters[:event_id] == 'fake-id'
    end
    Sidekiq::Testing.inline! { BackendDeleteApplicationWorker.perform_later('fake-id') }
  end
end
