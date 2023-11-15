# frozen_string_literal: true

module ThreeScale::SpamProtection

  class Configuration

    def initialize(controller)
      @controller = controller
      @store = @controller.store
      @store[:enabled_checks] = []

      @checks = {}
    end

    def enabled_checks
      @store[:enabled_checks]
    end

    def checks
      @checks.values
    end

    def check(name)
      @checks.fetch(name)
    end

    def enable_checks!(*checks)
      checks = checks.flatten

      enabled_checks.concat checks
      enabled_checks.uniq!

      initialize_checks!
    end

    def enabled?(check)
      enabled_checks.include?(check)
    end

    private
    def initialize_checks!
      enabled_checks.each do |check|
        # create empty hash for check configuration
        @store[check] ||= {}
        @checks[check] = ThreeScale::SpamProtection::Checks.const_get(check.to_s.camelize).new(@store)
      end
    end

  end

end
