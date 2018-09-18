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
    application = FactoryGirl.create(:simple_cinstance).reload # reload to get tenant_id
    FactoryGirl.create(:simple_admin, account: application.provider_account) # for the access token
    event = ZyncEvent.create(RailsEventStore::Event.new, application)

    worker.config.stubs(endpoint: 'http://example.com') # so it makes http request
    worker.publisher.call(event) # so it is later available to find

    stub_request(:put, 'http://example.com/tenant').to_return(status: 200)
    stub_request(:put, 'http://example.com/notification').to_return(status: 422)

    zync_events = RailsEventStoreActiveRecord::Event.where(event_type: 'ZyncEvent')

    ZyncWorker::MessageBusPublisher.expects(:enabled).returns(false)

    assert_difference(zync_events.method(:count), +2) do
      assert_raises ZyncWorker::UnprocessableEntityError do
        worker.perform(event.event_id, event.data.with_indifferent_access)
      end
    end
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
