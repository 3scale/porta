# frozen_string_literal: true

require 'test_helper'

class CreateServiceTokenWorkerTest < ActiveSupport::TestCase

  FakeEvent = Struct.new(:event_id, :service, :token_value)

  def test_enqueue
    CreateServiceTokenWorker.expects(:perform_async).once

    event = FakeEvent.new('12345')

    CreateServiceTokenWorker.enqueue(event)
  end

  def test_perform
    Sidekiq::Testing.inline! do
      token   = 'Alaska12345'
      service = FactoryBot.create(:simple_service, id: 999)
      service.service_tokens.delete_all
      event   = FakeEvent.new('1235', service, token)

      EventStore::Repository.expects(:find_event!).returns(event).twice
      ServiceTokenService.expects(:update_backend).with(instance_of(ServiceToken)).twice

      assert_difference ServiceToken.method(:count), +1 do
        CreateServiceTokenWorker.perform_async(event)
        # for one event there should be only one service token
        CreateServiceTokenWorker.perform_async(event)
      end
    end
  end

  def test_perform_reports_error_when_event_does_not_exist
    System::ErrorReporting.expects(:report_error).once.with do |exception, options|
      exception.is_a?(ActiveRecord::RecordNotFound) && (parameters = options[:parameters]) && parameters[:event_id] == 'fake-id'
    end
    Sidekiq::Testing.inline! { CreateServiceTokenWorker.perform_async('fake-id') }
  end

  class CreateServiceTokenWorkerDeserializationErrorTest < ActiveSupport::TestCase
    def setup
      @service = FactoryBot.create(:simple_service)
      @user = FactoryBot.create(:simple_user)
      @event = Services::ServiceCreatedEvent.create(service, user)
      Rails.application.config.event_store.publish_event(event)
    end

    attr_reader :service, :user, :event

    def test_perform_deserialization_error_no_service
      expected_log_message = /CreateServiceTokenWorker#perform raised ActiveJob::DeserializationError with message: Error while trying to deserialize arguments: Couldn't find Service with 'id'=#{service.id}/
      Rails.logger.stubs(:info) # There can be other logs as well :)
      Rails.logger.expects(:info).with { |message| message.match(expected_log_message) }

      service.delete
      Sidekiq::Testing.inline! { CreateServiceTokenWorker.perform_async(event.event_id) }
    end

    def test_perform_deserialization_error_no_user
      System::ErrorReporting.expects(:report_error).once.with do |exception, options|
        exception.is_a?(ActiveJob::DeserializationError) && (parameters = options[:parameters]) && parameters[:event_id] == event.event_id
      end

      user.delete
      Sidekiq::Testing.inline! { CreateServiceTokenWorker.perform_async(event.event_id) }
    end
  end
end
