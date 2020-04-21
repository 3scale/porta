# frozen_string_literal: true

require 'test_helper'

class ApplicationDeletedSubscriberTest < ActiveSupport::TestCase
  def test_create
    application = FactoryBot.build_stubbed(:simple_cinstance)
    event = Applications::ApplicationDeletedEvent.create_and_publish!(application)

    BackendDeleteApplicationWorker.expects(:perform_later).with(event.event_id)

    ApplicationDeletedSubscriber.new.after_commit(event)
  end
end
