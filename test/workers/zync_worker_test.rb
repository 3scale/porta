require 'test_helper'

class ZyncWorkerTest < ActiveSupport::TestCase
  setup do
    EventStore::Repository.stubs(raise_errors: true)
  end

  test 'perform raises ActiveRecord::RecordNotFound when the event does not exist' do
    ZyncWorker.any_instance.stubs(valid?: true)

    assert_raises(ActiveRecord::RecordNotFound) do
      ZyncWorker.new.perform('fake_event_id', 'fake notification')
    end
  end

  test 'perform does not crash when the event exists but the provider is destroyed' do
    worker = ZyncWorker.new
    application = FactoryBot.create(:simple_cinstance)
    app_event = Applications::ApplicationDeletedEvent.create_and_publish!(application)
    zync_event = ZyncEvent.create_and_publish!(app_event, application)
    worker.stubs(valid?: true)
    worker.stubs(endpoint: 'http://example.com')
    stub_request(:put, "http://example.com/notification").to_return(status: 200)

    application.provider_account.delete
    refute ZyncWorker.new.perform(zync_event.event_id, 'notification')
  end

  test 'http put got unprocessable entity' do
    worker = ZyncWorker.new

    stub_request(:put, 'http://example.com/').to_return(status: 422, headers: {})

    assert_raise ZyncWorker::UnprocessableEntityError do
      worker.http_put('http://example.com', nil, 'some-id')
    end
  end

  test 'sends authentication' do
    worker = ZyncWorker.new

    Rails.configuration.stubs(zync: ActiveSupport::InheritableOptions.new(authentication: { 'token' => token = 'sometoken'}))

    stub_request(:put, 'http://example.com/foo').
      with(headers: { 'Authorization' =>  ActionController::HttpAuthentication::Token.encode_credentials(token) }).
      to_return(status: 200, body: '', headers: {})

    worker.http_put('http://example.com/foo', 'somebody', 'some-id')
  end

  test 'tries to recreate dependencies' do
    worker = ZyncWorker.new
    application = FactoryBot.create(:simple_cinstance).reload # reload to get tenant_id
    FactoryBot.create(:simple_admin, account: application.provider_account) # for the access token
    event = ZyncEvent.create(RailsEventStore::Event.new, application)

    worker.config.stubs(endpoint: 'http://example.com') # so it makes http request
    worker.publisher.call(event) # so it is later available to find

    stub_request(:put, 'http://example.com/tenant').to_return(status: 200)
    stub_request(:put, 'http://example.com/notification').to_return(status: 422)

    zync_events = RailsEventStoreActiveRecord::Event.where(event_type: 'ZyncEvent')

    assert_difference(zync_events.method(:count), +2) do
      worker.perform(event.event_id, event.data.with_indifferent_access)
    end
  end

  class UnprocessableEntityRetryTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    attr_reader :worker, :event, :application

    setup do
      EventStore::Repository.stubs(raise_errors: true)

      @worker = ZyncWorker.new
      @application = FactoryBot.create(:simple_cinstance).reload # reload to get tenant_id
      FactoryBot.create(:simple_admin, account: application.provider_account) # for the access token
      @event = ZyncEvent.create(RailsEventStore::Event.new, application)

      worker.config.stubs(endpoint: 'http://example.com') # so it makes http request
      worker.publisher.call(event) # so it is later available to find

      stub_request(:put, 'http://example.com/tenant').to_return(status: 200)
      stub_request(:put, 'http://example.com/notification').to_return(status: 422).with(body: event.data.to_json) # causes UnprocessableEntityError to be raised
    end

    test 'sync event dependencies when it fails' do
      worker.expects(:sync_dependencies).with(event.event_id).returns(true)
      worker.perform(event.event_id, event.data.with_indifferent_access)
    end

    test 'raises the error when there is no dependency' do
      worker.expects(:sync_dependencies).with(event.event_id).returns([])
      assert_raises ZyncWorker::UnprocessableEntityError do
        worker.perform(event.event_id, event.data.with_indifferent_access)
      end
    end

    test '#create_dependency_events' do
      event_id = event.event_id
      EventStore::Repository.expects(:find_event!).with(event_id).returns(event)
      event.expects(:create_dependencies)
      worker.create_dependency_events(event_id)
    end

    test '#sync_dependencies publishes events and enqueues jobs' do
      event_id = event.event_id
      dependency_events = event.create_dependencies

      worker.expects(:create_dependency_events).with(event_id).returns(dependency_events)
      worker.expects(:publish_dependency_events).with(dependency_events)

      worker.sync_dependencies(event_id)
    end

    test '#publish_dependency_events enqueues the jobs' do
      %w[Proxy Service].each { |dependent_type| ZyncWorker.expects(:perform_async).with(anything, has_entry(:type, dependent_type)) }
      worker.publish_dependency_events(event.create_dependencies)
    end

    test 'on batch complete' do
      event_id = event.event_id
      klass = worker.class
      klass.expects(:perform_async).with(event_id, anything, 1)
      klass.new.on_complete(1, {'event_id' => event_id, 'manual_retry_count' => 0})
    end

    test 'number of attempts' do
      event_id = event.event_id
      retry_limit = worker.retry_limit

      dependency_events = []
      retry_limit.times { dependency_events << event.create_dependencies }

      dependency_events.flatten.each do |dependent_event|
        stub_request(:put, 'http://example.com/notification').to_return(status: 200).with(body: dependent_event.data.to_json)
      end

      Sidekiq::Testing.inline! do
        assert_raises(ZyncWorker::UnprocessableEntityError) do
          (retry_limit + 1).times do |attempt|
            worker.stubs(retry_attempt: attempt)
            worker.expects(:create_dependency_events).with(event_id).returns(dependency_events[attempt]) if attempt < retry_limit
            worker.perform(event_id, event.data.with_indifferent_access)
          end
        end
      end
    end

    test 'batch callback without manual retry count' do
      event_id = event.event_id
      worker.stubs(update_tenant: [ { id: event.tenant_id }, application.provider_account ])
      worker.expects(:http_put).raises(ZyncWorker::UnprocessableEntityError.new(mock(status: 422, as_json: {})))

      Sidekiq::Batch.any_instance.expects(:on).with(:complete, ZyncWorker, { 'event_id' => event_id, 'manual_retry_count' => nil })
      worker.perform(event_id, event.data.with_indifferent_access)
    end

    test 'batch callback with manual retry count' do
      event_id = event.event_id
      worker.stubs(update_tenant: [ { id: event.tenant_id }, application.provider_account ])
      worker.expects(:http_put).raises(ZyncWorker::UnprocessableEntityError.new(mock(status: 422, as_json: {})))

      Sidekiq::Batch.any_instance.expects(:on).with(:complete, ZyncWorker, { 'event_id' => event_id, 'manual_retry_count' => 5 })
      worker.perform(event_id, event.data.with_indifferent_access, 5)
    end

    test 'batch callback with manual retry count and sidekiq retry count' do
      event_id = event.event_id
      event_data = event.data.with_indifferent_access
      worker.stubs(update_tenant: [ { id: event.tenant_id }, application.provider_account ])
      worker.expects(:http_put).raises(ZyncWorker::UnprocessableEntityError.new(mock(status: 422, as_json: {})))

      worker.retry_attempt = 2

      Sidekiq::Batch.any_instance.expects(:on).with(:complete, ZyncWorker, { 'event_id' => event_id, 'manual_retry_count' => 5 })
      worker.perform(event_id, event_data, 5)
      refute worker.last_attempt?
    end

    test 'batch callback with manual retry count and sidekiq retry count summing last attempt' do
      event_id = event.event_id
      event_data = event.data.with_indifferent_access
      worker.stubs(update_tenant: [ { id: event.tenant_id }, application.provider_account ])
      worker.expects(:http_put).raises(ZyncWorker::UnprocessableEntityError.new(mock(status: 422, as_json: {})))

      worker.retry_attempt = 2

      worker.expects(:sync_dependencies).never
      Sidekiq::Batch.any_instance.expects(:on).with(:complete, ZyncWorker, { 'event_id' => event_id, 'manual_retry_count' => 23 }).never
      assert_raises(ZyncWorker::UnprocessableEntityError) { worker.perform(event_id, event_data, 23) }
      assert worker.last_attempt?
    end
  end

  test 'deleted application rebuilds dependency that can be performed' do
    application = FactoryBot.create(:simple_cinstance)
    FactoryBot.create(:admin, account: application.provider_account)
    application.service.proxy.delete
    application.reload.destroy!
    event_store_event = EventStore::Event.where(event_type: Applications::ApplicationDeletedEvent.to_s).last!
    application_event = EventStore::Repository.find_event!(event_store_event.event_id)
    ZyncEvent.create_and_publish!(application_event, application_event.application)

    Rails.configuration.zync.stubs(endpoint: 'http://example.com') # so it makes http request

    stub_request(:put, 'http://example.com/tenant').to_return(status: 200)
    stub_request(:put, 'http://example.com/notification').to_return(status: 422)

    zync_event = EventStore::Event.where(event_type: ZyncEvent.to_s).last!
    assert_difference(EventStore::Event.where(event_type: ZyncEvent.to_s).method(:count), +1) do
      Sidekiq::Testing.inline! { ZyncWorker.perform_async(zync_event.event_id, zync_event.data) }
    end

    stub_request(:put, 'http://example.com/notification').to_return(status: 200)

    dependency_event_service = EventStore::Event.where(event_type: ZyncEvent.to_s).last!
    assert_equal 'Service', dependency_event_service.data[:type]
    assert_equal zync_event.data[:service_id], dependency_event_service.data[:id]
    Sidekiq::Testing.inline! { ZyncWorker.perform_async( dependency_event_service.event_id,  dependency_event_service.data) }
  end
end
