# frozen_string_literal: true

require 'test_helper'

class ServiceDeletedSubscriberTest < ActiveSupport::TestCase
  def test_create
    service = FactoryBot.build_stubbed(:simple_service)
    event = Services::ServiceDeletedEvent.create(service)

    BackendDeleteEndUsersWorker.expects(:perform_async).with(service.id)

    ServiceDeletedSubscriber.new.after_commit(event)
  end
end
