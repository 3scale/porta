# -*- coding: utf-8 -*-
module ThreeScale::SpamProtection

  class Configuration
    CHECKS = [:honeypot, :javascript, :timestamp]
    LEVELS = [['Never', :none], ['Suspicious only', :auto], ['Always', :captcha]]

    delegate :[], :to => :@store


    def initialize(klass, store = {})
      @klass = klass
      @store = {}
      @store[:level] ||= 0.4
      @store[:enabled_checks] = []

      @checks = {}
    end

    def available_checks
      CHECKS
    end

    def enabled_checks
      @store[:enabled_checks]
    end

    def active_checks
      @checks.values
    end

    def check(name)
      @checks.fetch(name)
    end

    def enable_checks!(*checks)
      checks = checks.flatten

      enabled_checks.concat checks
      enabled_checks.uniq!

      initialize_checks!(checks)
    end
    alias enable_check! enable_checks!

    def enabled?(check)
      enabled_checks.include?(check)
    end

    private
    def initialize_checks!(checks)
      checks.each do |check|
        # create empty hash for check configuration
        @store[check] ||= {}
        @checks[check] = ThreeScale::SpamProtection::Checks.const_get(check.to_s.camelize).new(self)
      end

      apply!(checks)
    end

    def apply!(checks)
      @checks.values_at(*checks).each do |check|
        check.apply!(@klass)
      end
    end

  end

end
