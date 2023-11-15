# frozen_string_literal: true

module ThreeScale
  module SpamProtection
    AVAILABLE_CHECKS = [:honeypot, :javascript, :timestamp, :count]
    LEVELS = [['Never', :none], ['Suspicious only', :auto], ['Always', :captcha]]
    SPAM_THRESHOLD = 0.4
  end
end
