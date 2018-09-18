module TestHelpers
  module ToggleBackend
    def self.included(base)
      base.setup { BackendClient::ToggleBackend.disable_all! }
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::ToggleBackend)
