module TestHelpers
  module Assertions
    private

    def assert_valid(record, message = nil)
      assert record.valid?, message || record.errors.full_messages.to_sentence
    end

    def refute_valid(record, message = nil)
      refute_predicate record, :valid?, message
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Assertions)
