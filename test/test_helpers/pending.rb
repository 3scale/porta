module TestHelpers
  module Pending
    # Use this to temporarily disable a test
    def pending_test(name, &block)
      test(name) { puts "  * WARNING: Test: <#{self}> is pending." }
    end
  end
end

ActiveSupport::TestCase.extend(TestHelpers::Pending)
