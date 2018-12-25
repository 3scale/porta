require 'test_helper'

class Logic::RollingUpdatesTest < ActiveSupport::TestCase

  setup do
    Logic::RollingUpdates.stubs(:enabled? => true)
    System::ErrorReporting.expects(:report_error).never
  end

  def test_policies
    account = FactoryBot.build_stubbed(:simple_account)

    Logic::RollingUpdates::Features::Yaml.stubs(:config).returns({ policies: true })
    assert account.provider_can_use?(:policies)

    Logic::RollingUpdates::Features::Yaml.stubs(:config).returns({ policies: false })
    refute account.provider_can_use?(:policies)
  end

  def test_forum
    account = FactoryBot.build_stubbed(:simple_account)

    Logic::RollingUpdates::Features::Yaml.stubs(:config).returns({ forum: true })
    assert account.provider_can_use?(:forum)

    Logic::RollingUpdates::Features::Yaml.stubs(:config).returns({ forum: false })
    refute account.provider_can_use?(:forum)
  end

  def test_cms_api
    account = FactoryBot.build_stubbed(:simple_account)

    Rails.configuration.three_scale.rolling_updates.stubs(features: { cms_api: [account.id] })
    assert account.provider_can_use?(:cms_api)
    assert account.provider_can_use?('cms_api')
  end

  def test_feature
    assert Logic::RollingUpdates.feature(:service_permissions)

    assert_raise Logic::RollingUpdates::UnknownFeatureError do
      Logic::RollingUpdates.feature(:unknown_feature)
    end
  end

  def test_enterprise
    account = FactoryBot.build_stubbed(:simple_account)
    plan    = FactoryBot.build_stubbed(:simple_application_plan, system_name: 'alex')

    account.expects(:bought_plan).returns(plan).at_least_once
    account.expects(:has_bought_cinstance?).returns(true).at_least_once

    refute account.provider_can_use?(:service_permissions)

    plan.system_name = 'superplan_enterprise_superplan'

    assert account.provider_can_use?(:service_permissions)
  end

  test "Provider: provider_can_use? returns false if you're not in the list" do
    provider = Account.new
    refute provider.provider_can_use?(:instant_bill_plan_change)
  end


  test "Provider: provider_can_use? raise error for unkown features" do
    Rails.configuration.three_scale.rolling_updates.stubs(raise_error_unknown_features: true)

    provider = Account.new

    assert_raise Logic::RollingUpdates::UnknownFeatureError  do
      provider.provider_can_use?(:foobar)
    end
  end

  test "Provider: provider_can_use? return false for unkown features" do
    Rails.configuration.three_scale.rolling_updates.stubs(raise_error_unknown_features: false)
    System::ErrorReporting.expects(:report_error).never

    provider = Account.new
    refute provider.provider_can_use?(:foobar)
  end

  test "Provider: provider_can_use? delegates to provider_account if account is actually a buyer" do
    Rails.configuration.three_scale.rolling_updates.stubs(raise_error_unknown_features: false)

    provider = FactoryBot.build_stubbed(:simple_provider)
    buyer = FactoryBot.build_stubbed(:simple_buyer, provider_account: provider)

    provider.expects(:provider_can_use?).returns(false).once
    buyer.send(:provider_can_use?, :whatever)
  end

  test "Controller: provider_can_use? return true if it is the impersonation admin user" do
    controller_instance = mocked_controller

    user = User.new(username: ThreeScale.config.impersonation_admin['username'])
    controller_instance.expects(:current_user).returns(user).once

    assert controller_instance.send(:provider_can_use?, :whathever)
  end

  test "Controller: provider_can_use? delegate to current_account" do
    controller_instance = mocked_controller

    user = User.new
    controller_instance.expects(:current_user).returns(user).once

    provider = Account.new
    provider.expects(:provider_can_use?).with(:whathever)
    controller_instance.expects(:current_account).returns(provider).once

    controller_instance.send(:provider_can_use?, :whathever)
  end

  test 'provider can use duplicate_user_key feature' do
    Rails.configuration.three_scale.rolling_updates.stubs(features: {duplicate_user_key: [1,3]})
    provider_1, provider_2 = Account.new, Account.new

    provider_1.stubs(:id).returns(1)
    provider_2.stubs(:id).returns(2)

    assert provider_1.provider_can_use?(:duplicate_user_key)
      refute provider_2.provider_can_use?(:duplicate_user_key)
  end

  class NewFeature < Logic::RollingUpdates::Features::Base
    def missing_config
      true
    end
  end

  test 'custom feature configuration' do
    Logic::RollingUpdates::Features::Base.any_instance.stubs(:yaml_config).returns({custom_feature: nil})

    provider = Account.new

    assert NewFeature.new(provider).enabled?, true
  end

  test 'when there is no yml config it should call feature missing_config' do
    Rails.configuration.three_scale.rolling_updates.stubs(features: nil)

    provider = Account.new

    NewFeature.any_instance.expects(:missing_config).returns(true).at_least_once
    assert NewFeature.new(provider).enabled?, true
  end

  test 'async apicast deploy' do
    provider = Account.new

    refute provider.rolling_update(:async_apicast_deploy).missing_config
  end

  test 'require cc on signup' do
    provider = Account.new

    refute provider.rolling_update(:require_cc_on_signup).missing_config
  end

  test 'admin portal sso' do
    provider = FactoryBot.build_stubbed(:simple_provider)
    provider.stubs(enterprise?: true)

    assert provider.provider_can_use?(:provider_sso)
  end

  private

  def mocked_controller
    controller_class = Class.new do
      def self.helper_method(*); end
      include Logic::RollingUpdates::Controller
    end

    controller_class.new
  end
end
