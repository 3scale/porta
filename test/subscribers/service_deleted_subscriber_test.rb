# frozen_string_literal: true

require 'test_helper'

class ServiceDeletedSubscriberTest < ActiveSupport::TestCase
  def test_create
    service = FactoryBot.build_stubbed(:simple_service)
    event = Services::ServiceDeletedEvent.create(service)

    BackendDeleteEndUsersWorker.expects(:enqueue).with(event)

    ServiceDeletedSubscriber.new.after_commit(event)
  end
end
