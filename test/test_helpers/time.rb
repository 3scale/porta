module TestHelpers
  module Time
    def self.included(base)
      base.setup(:reset_timezone)
      base.teardown(:reset_timezone)
    end

    def reset_timezone
      ::Time.zone = System::Application.config.time_zone
    end

    # platform independent way to get monotonic timer seconds
    def monotonic_seconds
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Time
end
