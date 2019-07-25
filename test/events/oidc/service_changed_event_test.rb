# frozen_string_literal: true

require 'test_helper'

class OIDC::ServiceChangedEventTest < ActiveSupport::TestCase
  def test_create
    EventStore::Repository.stubs(raise_errors: true)

    service = FactoryBot.create(:simple_service)

    assert_instance_of OIDC::ServiceChangedEvent, OIDC::ServiceChangedEvent.create_and_publish!(service)
  end
end
