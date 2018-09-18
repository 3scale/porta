module TestHelpers
  module Pending
    # Use this to temporarily disable a test
    def pending_test(name, &block)
      test(name) { puts "  * WARNING: Test: <#{self}> is pending." }
    end

    # Use this to temporarily disable whole shoulda context
    def pending_context(name = nil, &block)
      puts "  * WARNING: Context <#{name}> in <#{self}> is pending."
    end
  end
end

ActiveSupport::TestCase.extend(TestHelpers::Pending)
