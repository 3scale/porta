# frozen_string_literal: true

module TestHelpers
  module CaptureLogMessages
    # Runs the block once and returns the lines that `Rails.logger` received, at any severity.
    # Unlike a mock expectation on `Rails.logger`, it doesn't fail on unrelated log calls.
    #
    #   messages = capture_log_messages { relation.to_a }
    #   assert_empty messages.grep(/WillPaginateMysqlOptimizedLookup/)
    #
    # :reek:UtilityFunction
    def capture_log_messages
      output = StringIO.new
      logger = ActiveSupport::Logger.new(output)
      logger.level = Logger::DEBUG
      Rails.logger.broadcast_to(logger)
      yield
      output.string.lines.map(&:chomp)
    ensure
      Rails.logger.stop_broadcasting_to(logger)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::CaptureLogMessages)
