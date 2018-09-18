require 'test_helper'
require_relative 'report_base_event_test'

class Reports::DailyReportEventTest < Reports::ReportBaseEventTest
  self.event_class = Reports::DailyReportEvent
end
