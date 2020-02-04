require 'test_helper'

class ThreeScale::ErrorRerortingIgnoreEnduserTest < ActiveSupport::TestCase

  class Double
    include ::ThreeScale::ErrorReportingIgnoreEnduser
  end

  class WithNewRelicTest < self
    def test_interface
      Double.expects(:new_relic_instrumentation?).returns(true)
      Double.expects(:newrelic_ignore_enduser).once
      Double.error_reporting_ignore_enduser
    end
  end

  class NoNewRelicTest < self
    def test_interface
      Double.expects(:new_relic_instrumentation?).returns(false)
      Double.expects(:newrelic_ignore_enduser).never
      Double.error_reporting_ignore_enduser
    end
  end
end
