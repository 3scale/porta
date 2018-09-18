require 'test_helper'

class Reports::CsvDataExportEventTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def test_create
    provider  = FactoryGirl.build_stubbed(:simple_provider)
    recipient = FactoryGirl.build_stubbed(:simple_user)
    event     = Reports::CsvDataExportEvent.create(provider, recipient, 'users', 'week')

    assert event
    assert_equal event.provider, provider
    assert_equal event.recipient, recipient
    assert_equal event.type, 'users'
    assert_equal event.period, 'week'
    assert_equal event.metadata[:provider_id], provider.id
  end

  def test_create_period
    provider = FactoryGirl.build_stubbed(:simple_provider)
    recipient = FactoryGirl.build_stubbed(:simple_user)

    event = Reports::CsvDataExportEvent.create(provider, recipient, 'users', '')

    assert_equal 'all', event.period
  end
end
