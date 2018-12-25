require 'test_helper'

class Reports::ReportBaseEventTest < ActiveSupport::TestCase
  class_attribute :event_class
  self.event_class = Reports::ReportBaseEvent

  def test_create
    service = FactoryBot.create(:simple_service)
    provider = service.account
    report = Pdf::Report.new(provider, service, period: :week)
    event = event_class.create(report)

    assert event

    assert_equal provider, event.account
    assert_equal service, event.service
    assert_equal :week, event.period

    assert_equal provider.id, event.metadata.fetch(:provider_id)
  end
end
