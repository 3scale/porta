module TestHelpers
  module RollingUpdates
    module_function

    def rolling_updates_off
      ::Logic::RollingUpdates.unstub(:skipped?)
      ::Account.any_instance.unstub(:provider_can_use?)

      ::Logic::RollingUpdates.stubs(skipped?: true)
      ::Account.any_instance.stubs(:provider_can_use?).returns(false)
    end

    def rolling_updates_on
      ::Logic::RollingUpdates.unstub(:enabled?)
      ::Logic::RollingUpdates.stubs(enabled?: false)
    end

    def rolling_update(name, enabled:)
      ::Account.any_instance.expects(:provider_can_use?).with(name.try(:to_sym) || name).returns(enabled).at_least_once
    end
  end

  ActiveSupport::TestCase.send(:include, RollingUpdates)
end
