require 'test_helper'

class ZyncWorkerTest < ActiveSupport::TestCase
  setup do
    EventStore::Repository.stubs(raise_errors: true)
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

    ZyncWorker::MessageBusPublisher.expects(:enabled).returns(false)

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
      EventStore::Repository.expects(:find_event!).returns(event)
      event.expects(:create_dependencies)
      worker.create_dependency_events(event.event_id)
    end

    test '#sync_dependencies publishes events and enqueues jobs' do
      event_id = event.event_id
      dependency_events = event.create_dependencies

      worker.expects(:create_dependency_events).with(event_id).returns(dependency_events)
      worker.expects(:publish_dependency_events).with(dependency_events)

      worker.sync_dependencies(event_id)
    end

    test '#publish_dependency_events enqueues the jobs' do
      event_id = event.event_id
      dependency_events = event.create_dependencies

      %w[Proxy Service].each { |dependent_type| ZyncWorker.expects(:perform_async).with(anything, has_entry(:type, dependent_type)) }
      worker.publish_dependency_events(dependency_events)
    end

    test 'on batch complete' do
      event_id = event.event_id
      klass = worker.class
      klass.expects(:perform_async).with(event_id, anything)
      klass.new.on_complete(1, {'event_id' => event_id})
    end

    test 'number of attempts' do
      ZyncWorker::MessageBusPublisher.any_instance.stubs(enabled?: false)

      retry_limit = worker.retry_limit

      dependency_events = {}
      retry_limit.times { |i| dependency_events[i] = event.create_dependencies }

      dependency_events.values.flatten.each do |dependent_event|
        stub_request(:put, 'http://example.com/notification').to_return(status: 200).with(body: dependent_event.data.to_json)
      end

      worker.expects(:create_dependency_events).with(event.event_id).times(3)
            .returns(dependency_events[0])
            .then.returns(dependency_events[1])
            .then.returns(dependency_events[2])

      Sidekiq::Testing.inline! do
        assert_raises(ZyncWorker::UnprocessableEntityError) do
          (retry_limit + 1).times do |attempt|
            worker.retry_attempt = attempt
            worker.perform(event.event_id, event.data.with_indifferent_access)
          end
        end
      end
    end
  end

  test 'deleted application rebuilds dependency that can be performed' do
    application = FactoryBot.create(:simple_cinstance)
    FactoryBot.create(:admin, account: application.provider_account)
    application.service.proxy.delete
    application.reload.destroy!
    event_store_event = EventStore::Event.where(event_type: Applications::ApplicationDeletedEvent).last!
    application_event = EventStore::Repository.find_event!(event_store_event.event_id)
    ZyncEvent.create_and_publish!(application_event, application_event.application)

    Rails.configuration.zync.stubs(endpoint: 'http://example.com') # so it makes http request
    Rails.configuration.zync.stubs(message_bus: true)

    stub_request(:put, 'http://example.com/tenant').to_return(status: 200)
    stub_request(:put, 'http://example.com/notification').to_return(status: 422)

    zync_event = EventStore::Event.where(event_type: ZyncEvent).last!
    assert_difference(EventStore::Event.where(event_type: ZyncEvent).method(:count), +1) do
      Sidekiq::Testing.inline! { ZyncWorker.perform_async(zync_event.event_id, zync_event.data) }
    end

    stub_request(:put, 'http://example.com/notification').to_return(status: 200)

    dependency_event_service = EventStore::Event.where(event_type: ZyncEvent).last!
    assert_equal 'Service', dependency_event_service.data[:type]
    assert_equal zync_event.data[:service_id], dependency_event_service.data[:id]
    Sidekiq::Testing.inline! { ZyncWorker.perform_async( dependency_event_service.event_id,  dependency_event_service.data) }
  end

  class MessageBusPublisherTest < ActiveSupport::TestCase
    test 'enabled only for proxy' do
      ZyncWorker::MessageBusPublisher.stubs(enabled: true)

      refute_predicate ZyncWorker::MessageBusPublisher.new(type: 'Application', id: 42), :enabled?
      refute_predicate ZyncWorker::MessageBusPublisher.new(type: 'Service', id: 42), :enabled?
      assert_predicate ZyncWorker::MessageBusPublisher.new(type: 'Proxy', id: 42), :enabled?
    end

    test 'wait_for' do
      publisher = ZyncWorker::MessageBusPublisher.new({})
      queue = Queue.new

      assert_raises ZyncWorker::MessageBusPublisher::MessageBusTimeoutError do
        publisher.wait_for(queue, timeout: 0.1)
      end
    end
  end
end
