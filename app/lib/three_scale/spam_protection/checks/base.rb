module ThreeScale::SpamProtection
  module Checks

    class Base
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def name
        self.class.to_s.underscore
      end

      def apply!(klass)
        # do nothing
      end

      def invalid?(object)
        # do nothing
      end

      private
      def fail(value, probability = 1)
        Rails.logger.info("[SpamProtection] #{name} failed with value #{value.inspect}. Spam probability: #{probability}")
        probability
      end

    end
  end
end
