module TestHelpers
  module Paperclip
    def self.included(base)
      base.setup(:reset_paperclip_instances)
      base.teardown(:reset_paperclip_instances)
    end

    def reset_paperclip_instances
      # To clean cached s3 clients between tests
      Thread.current[:paperclip_s3_instances] = nil
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Paperclip
end
