# frozen_string_literal: true

require 'test_helper'

class Domains::ProviderDomainsChangedEventTest < ActiveSupport::TestCase
  test 'can be persisted' do
    provider = FactoryBot.create(:simple_provider)
    event = Domains::ProviderDomainsChangedEvent.create_and_publish!(provider)

    assert EventStore::Repository.find_event(event.event_id)
  end
end
