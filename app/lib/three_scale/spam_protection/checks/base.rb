# frozen_string_literal: true

module ThreeScale::SpamProtection
  module Checks

    HIDE_STYLE = "position: absolute; width: 1px; height: 0; left: 0; overflow: hidden;"
    SPAM_CHECKS_SECRET_KEY = -> { Rails.application.key_generator.generate_key('spam-protection-checks', 32) }

    class SpamDetectedError < StandardError; end

    class Base
      def initialize(store)
        @store = store
      end

      def input(_form)
        ""
      end

      def name
        self.class.to_s.underscore
      end

      private

      def encryptor
        @encryptor ||= ActiveSupport::MessageEncryptor.new(SPAM_CHECKS_SECRET_KEY.call)
      end

      def encode(text)
        encryptor.encrypt_and_sign(text)
      end

      def decode(text)
        encryptor.decrypt_and_verify(text)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        raise ArgumentError
      end

      def add_to_average(value)
        Rails.logger.info("[SpamProtection] #{name} succeeded. Spam probability: #{value}")
        value
      end

      def fail_check(value, probability = 1)
        Rails.logger.info("[SpamProtection] #{name} failed with value #{value.inspect}. Spam probability: #{probability}")
        probability
      end
    end
  end
end
