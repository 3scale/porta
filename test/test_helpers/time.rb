require 'minitest/mock'

module TestHelpers
  module Time
    def self.included(base)
      base.setup(:reset_timezone)
      base.teardown(:reset_timezone)
    end

    def reset_timezone
      ::Time.zone = System::Application.config.time_zone
    end

    # Every call to Time.now increases a second.
    # This way we ensure multiple operations like :touch happening
    # in the same second end up being recorded in different seconds
    # Useful for time sensitive tests over DB engines which time
    # granularity is a second. e.g. MySQL.
    def with_clock_incrementing_on_each_read(&)
      time = ::Time.now

      ::Time.stub(:now, -> { time += 1.second }, &)
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Time
end
