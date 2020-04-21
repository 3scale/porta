# frozen_string_literal: true

require 'test_helper'

class BackendDeleteApplicationWorkerTest < ActiveSupport::TestCase
  test 'perform' do
    application = FactoryBot.create(:simple_cinstance)
    service = application.plan.service

    app_keys = FactoryBot.build_stubbed_list(:application_key, 2, application: application)
    app_keys.each { |app_key| DeletedObject.create(owner: application, object: app_key, metadata: {value: app_key.value}) }
    ref_filters = FactoryBot.build_stubbed_list(:referrer_filter, 2, application: application)
    ref_filters.each { |ref_filter| DeletedObject.create(owner: application, object: ref_filter, metadata: {value: ref_filter.value}) }

    seq = sequence('destroy sequence')
    app_keys.each { |app_key| ThreeScale::Core::ApplicationKey.expects(:delete).with(service.id.to_s, application.application_id, app_key.value).in_sequence(seq) }
    ref_filters.each { |ref_filter| ThreeScale::Core::ApplicationReferrerFilter.expects(:delete).with(service.id.to_s, application.application_id, ref_filter.value).in_sequence(seq) }
    ThreeScale::Core::Application.expects(:delete_id_by_key).with(service.id.to_s, application.user_key).in_sequence(seq)
    ThreeScale::Core::Application.expects(:delete).with(service.id.to_s, application.application_id).in_sequence(seq)

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
