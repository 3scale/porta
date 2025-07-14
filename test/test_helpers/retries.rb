module TestHelpers
  module Retries
    private

    def retry_assertions(times:, interval: 1.second)
      error = nil

      times.times do
        return yield
      rescue Minitest::Assertion => exception
        error = exception
        sleep interval
      end

      raise error
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Retries)
