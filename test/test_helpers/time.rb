module TestHelpers
  module Time
    def self.included(base)
      base.setup(:reset_timezone)
      base.teardown(:reset_timezone)
    end

    def reset_timezone
      ::Time.zone = System::Application.config.time_zone
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Time
end
