# frozen_string_literal: true

module ThreeScale::SpamProtection
  class Protector
    attr_reader :config

    def initialize(controller)
      @controller = controller
      @config = @controller.spam_protection_conf

      # create hash with checks as keys
      @checks = config.checks
    end

    def spam_probability
      probability = @checks.reduce(0) { |sum, check| sum + check.probability(@controller) }
      probability.to_f / @checks.count # No check is sure it detected a bot, return an average
    rescue ThreeScale::SpamProtection::Checks::SpamDetectedError
      1 # One check is sure it detected a bot, return 100% probability
    end

    def spam?
      probability = spam_probability
      Rails.logger.info { "[SpamProtection] probability is #{probability} and allowed level is #{SPAM_THRESHOLD}" }
      probability >= SPAM_THRESHOLD
    end
  end
end
