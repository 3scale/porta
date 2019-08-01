# frozen_string_literal: true

module TestHelpers
  module RollingUpdates
    module_function

    def rolling_updates_off
      swicth_rolling_updates false
    end

    def rolling_updates_on
      swicth_rolling_updates true
    end

    def swicth_rolling_updates(enabled)
      ::Logic::RollingUpdates.unstub(:skipped?)
      ::Logic::RollingUpdates.unstub(:enabled?)
      ::Account.any_instance.unstub(:provider_can_use?)

      ::Logic::RollingUpdates.stubs(skipped?: !enabled)
      ::Logic::RollingUpdates.stubs(enabled?: !!enabled)
      ::Account.any_instance.stubs(:provider_can_use?).returns(!!enabled)
    end

    def rolling_update(name, enabled:)
      ::Account.any_instance.expects(:provider_can_use?).with(name.try(:to_sym) || name).returns(enabled).at_least_once
    end
  end

  ActiveSupport::TestCase.send(:include, RollingUpdates)
end
