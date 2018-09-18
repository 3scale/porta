require 'test_helper'

class ThreeScale::MethodTrackingTest < ActiveSupport::TestCase

  class Double
    include ::ThreeScale::MethodTracing
  end

  class WithNewRelicTest < self
    def test_interface
      Double.expects(:new_relic_method_tracer?).returns(true)
      Double.expects(:add_method_tracer).once
      Double.add_three_scale_method_tracer
    end
  end

  class NoNewRelicTest < self
    def test_interface
      Double.expects(:new_relic_method_tracer?).returns(false)
      Double.expects(:add_method_tracer).never
      Double.add_three_scale_method_tracer
    end
  end
end
