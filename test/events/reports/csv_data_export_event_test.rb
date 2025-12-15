# frozen_string_literal: true

require 'test_helper'

class Reports::CsvDataExportEventTest < ActiveSupport::TestCase
  def test_create
    provider  = FactoryBot.build_stubbed(:simple_provider)
    recipient = FactoryBot.build_stubbed(:simple_user)
    event     = Reports::CsvDataExportEvent.create(provider, recipient, 'users', 'week')

    assert event
    assert_equal event.provider, provider
    assert_equal event.recipient, recipient
    assert_equal event.type, 'users'
    assert_equal event.period, 'week'
    assert_equal event.metadata[:provider_id], provider.id
  end
end
