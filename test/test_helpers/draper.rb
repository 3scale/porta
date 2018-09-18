module TestHelpers
  module Draper
    def self.included(base)
      base.teardown { ::Draper::ViewContext.clear! }
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Draper)
