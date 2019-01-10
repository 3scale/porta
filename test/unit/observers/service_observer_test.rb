require 'test_helper'

class ServiceObserverTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def test_after_create
    service = FactoryBot.build(:service)

    Services::ServiceCreatedEvent.expects(:create).once

    service.save!
  end
end
