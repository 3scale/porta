require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ServiceTest < ActiveSupport::TestCase

  def test_create_default_proxy
    Service.any_instance.expects(:create_proxy!).at_least_once
    FactoryGirl.create(:simple_service, proxy: nil)

    Service.any_instance.expects(:create_proxy!).never
    service = FactoryGirl.create(:simple_service, proxy: FactoryGirl.build(:proxy))
    assert_not_nil service.proxy
  end

  def test_backend_version=
    service = FactoryGirl.build_stubbed(:simple_service)
    service.backend_version = 'oauth'
    assert_equal 'oauth', service.backend_version
    assert_equal 'oauth', service.proxy.authentication_method

    service.backend_version = 'oidc'
    assert_equal 'oauth', service.backend_version
    assert_equal 'oidc', service.proxy.authentication_method
  end

  def test_parameterized_system_name
    service = Service.new(system_name: 'api_2')

    assert_equal 'api-2', service.parameterized_system_name
  end

  # Backward compatibility with providers that still have default service.
  # It cannot be deleted in backend that is why we need this
  def test_stop_destroy_if_last_default
    service = FactoryGirl.create(:simple_service)

    service.expects(:default?).returns(true)

    service.destroy

    assert service.reload

    service.expects(:destroyed_by_association).returns(Account.new)

    service.destroy

    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end

  def test_create_with_plugin
    service = FactoryGirl.build(:simple_service, deployment_option: 'plugin_rest')

    assert service.save!
  end

  def test_deployment_option=
    FactoryGirl.create(:simple_service, deployment_option: 'self_managed')

    service = Service.last!
    service.update_attributes!(deployment_option: 'hosted')

    proxy = service.proxy

    assert_predicate proxy, :valid?
    assert_predicate proxy, :persisted?

    assert proxy.production_endpoint
    assert proxy.staging_endpoint
  end

  # Now the last remaining service cannot be destroyed
  def test_stop_destroy_if_last
    service = FactoryGirl.create(:simple_service)

    service.expects(:last_accessible?).returns(true)

    service.destroy

    assert service.reload

    service.expects(:destroyed_by_association).returns(Account.new)

    service.destroy

    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end

  def test_update_account_default_service
    default_service = FactoryGirl.create(:simple_service)
    other_service   = FactoryGirl.create(:simple_service)
    account         = FactoryGirl.create(:simple_account,
                                         services: [default_service, other_service],
                                         default_service_id: default_service.id)

    assert_equal account.default_service_id, default_service.id

    other_service.destroy

    account.reload

    assert_equal default_service.id, account.default_service_id

    default_service.destroy_default
    assert default_service.destroyed?

    account.reload

    assert_nil account.default_service_id
  end

  test 'backend_authentication_type' do
    service = Service.new(account: account = Account.new)

    assert_equal :service_token, service.backend_authentication_type

    account.expects(:provider_can_use?).with(:apicast_per_service).returns(false)
    assert_equal :provider_key, service.backend_authentication_type
  end

  test 'backend_authentication_value' do
    service = Service.new(account: account = Account.new)

    service.expects(:service_token).returns('token').once

    assert_equal 'token', service.backend_authentication_value

    service.expects(:backend_authentication_type).returns(:provider_key).once
    account.expects(:provider_key).returns('key').once

    assert_equal 'key', service.backend_authentication_value
  end

  test 'service_token' do
    service = Service.new { |s| s.account_id = 42; s.system_name = 'foo' }
    service.save(validate: false)

    refute service.service_token

    service.service_tokens.create!(value: 'foobar')

    assert_equal 'foobar', service.service_token
  end

  test 'has friendly human attribute names' do
    assert_equal 'URL', Service.human_attribute_name('friendly_id')
  end

  should 'not be able to disable end user registration' do
    @service = Service.create!(:account => Factory(:simple_provider), :name => 'PandaCam')
    @service.end_user_registration_required = false

    assert @service.invalid?
    assert @service.errors[:end_user_registration_required].presence

    @service.account.settings.allow_end_users!
    @service.reload

    assert @service.valid?
  end

  should 'be in incomplete state' do
    @service = Service.create!(:account => Factory(:simple_provider), :name => 'PandaCam')
    assert @service.incomplete?
  end

  should 'have default metrics' do
    @service = Service.create!(:account => Factory(:simple_provider), :name => 'PandaCam')
    assert_not_nil @service.metrics.first
    assert_equal 'hits', @service.metrics.first.name
  end

  test 'alert_limits' do
   service = Factory(:simple_service)
   ThreeScale::Core::AlertLimit.expects(:load_all).with(service.backend_id).returns([])
   service.send(:alert_limits)
  end

  test 'delete_alert_limits' do
    service = Factory(:simple_service)
    ThreeScale::Core::AlertLimit.expects(:delete).with(service.backend_id, :foo)
    service.send(:delete_alert_limits, :foo)
  end

  test 'create_alert_limits' do
    service = Factory(:simple_service)
    ThreeScale::Core::AlertLimit.expects(:save).with(service.backend_id, :foo)
    service.send(:create_alert_limits, :foo)
  end

  test 'Service#cinstances returns cinstances of plans of the service' do
    service = Factory(:simple_service)
    plan = Factory(:application_plan, :issuer => service)
    buyer_account = Factory(:simple_buyer)

    cinstance = buyer_account.buy!(plan)
    assert_contains service.cinstances, cinstance
  end

  test '#has_traffic?' do
    service = Factory(:simple_service)
    plan = Factory(:application_plan, :issuer => service)

    buyer1 = Factory(:simple_buyer)
    buyer2 = Factory(:simple_buyer)

    app1 = buyer1.buy!(plan)
    buyer2.buy!(plan)

    assert_equal false, service.has_traffic?

    app1.update_attribute(:first_traffic_at, Time.zone.now)
    assert_equal true, service.has_traffic?
  end

  test '#mode_type' do
    assert_nil Service.new.mode_type

    service = FactoryGirl.create(:simple_service)

    service.assign_attributes(deployment_option: 'hosted', backend_version: '1')
    assert_equal :hosted, service.mode_type

    service.assign_attributes(deployment_option: 'self_managed', backend_version: '1')
    assert_equal :self_managed, service.mode_type

    service.assign_attributes(deployment_option: 'self_managed', backend_version: 'oauth')
    assert_equal :oauth, service.mode_type
  end

  test 'Service#cinstances does not return destroyed cinstances' do
    service = Factory(:simple_service)
    plan = Factory(:application_plan, :issuer => service)
    buyer_account = Factory(:simple_buyer)

    cinstance = buyer_account.buy!(plan)
    cinstance.destroy

    assert_does_not_contain service.cinstances, cinstance
  end

  test 'Service#cinstances returns read-write cinstances' do
    service = Factory(:simple_service)
    plan = Factory(:application_plan, :issuer => service)
    buyer_account = Factory(:simple_buyer)

    buyer_account.buy!(plan)

    refute service.cinstances.first.readonly?
  end

  context 'has_method_metrics?' do
    setup do
      @service = Factory(:simple_service)
      @metric = @service.metrics.first
    end

    should 'return true if metric hits has children' do
      @metric.children.create!(:system_name => 'foos', :friendly_name => 'Foos')
      assert @service.has_method_metrics?
    end

    should 'return false if metric hits does not have children' do
      refute @service.has_method_metrics?
    end
  end

  context 'method_metrics' do
    setup do
      @service = Factory(:simple_service)
      @hits = @service.metrics.hits!
    end

    should 'return only metrics that are children of hits' do
      method_1 = @hits.children.create!(friendly_name: 'Foos')
      method_2 = @hits.children.create!(friendly_name: 'Bars')

      assert_equal 'foos', method_1.system_name

      Factory(:metric, :service => @service)

      assert_same_elements [method_1, method_2], @service.method_metrics
    end

    should 'return null relation if service has no methods defined' do
      assert_equal Metric.none, @service.method_metrics
    end
  end

  test "default service cannot be destroyed" do
    provider = Factory :provider_account
    service  = provider.default_service

    service.destroy
    assert service.reload
    assert service.errors.present?
  end

  test "#destroy_default destroys a default service" do
    provider = Factory :provider_account
    service  = provider.default_service

    service.destroy_default
    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end

  def test_default_service_plan
    service = FactoryGirl.build(:simple_service)
    service.account.settings.service_plans_ui_visible = true

    service.save!
    
    service_plan = service.service_plans.first!
    assert_equal 'hidden', service_plan.state
  end

  def test_default_published_service_plan
    Logic::RollingUpdates.stubs(skipped?: true)

    service = FactoryGirl.build(:simple_service)
    service.account.settings.service_plans_ui_visible = false

    service.save!

    service_plan = service.service_plans.first!
    assert_equal 'hidden', service_plan.state
  end

  def test_default_published_service_plan_with_rolling_update
    Logic::RollingUpdates.stubs(enabled?: true, skipped?: false)

    service = FactoryGirl.build(:simple_service)
    service.account.settings.service_plans_ui_visible = false

    Logic::RollingUpdates.feature(:published_service_plan_signup).any_instance.expects(:missing_config).returns(true)
    service.save!

    service_plan = service.service_plans.first!
    assert_equal 'published', service_plan.state
  end

  class DestroyingServiceTest < ActiveSupport::TestCase

    disable_transactional_fixtures!

    test "destroying service destroys it's plans" do
      service          = FactoryGirl.create(:service)
      service_plan     = FactoryGirl.create(:application_plan, issuer: service)
      application_plan = FactoryGirl.create(:service_plan, issuer: service)

      service.destroy

      assert_raise(ActiveRecord::RecordNotFound) { application_plan.reload }
      assert_raise(ActiveRecord::RecordNotFound) { service_plan.reload }
    end

    test "destroying service destroys it's features" do
      service = FactoryGirl.create(:service)
      feature = FactoryGirl.create(:feature, featurable: service)

      service.destroy

      assert_nil Feature.find_by_id(feature.id)
    end

    test "destroying service destroys it's metrics" do
      service = FactoryGirl.create(:service)
      metric  = FactoryGirl.create(:metric, service: service)

      service.destroy

      assert_nil Metric.find_by_id(metric.id)
    end

    test 'destroying service creates a related event' do
      service          = FactoryGirl.create(:service)
      service_plan     = FactoryGirl.create(:service_plan, issuer: service)
      service_contract = FactoryGirl.create(:service_contract, plan: service_plan)
      application_plan = FactoryGirl.create(:application_plan, issuer: service)
      cinstance        = FactoryGirl.create(:cinstance, plan: application_plan)

      assert_difference(RailsEventStoreActiveRecord::Event.where(
        event_type: 'Services::ServiceDeletedEvent').method(:count), +1) do

        service.destroy_default
      end

      assert_raise(ActiveRecord::RecordNotFound) { service_contract.reload }
      assert_raise(ActiveRecord::RecordNotFound) { application_plan.reload }
      assert_raise(ActiveRecord::RecordNotFound) { cinstance.reload }
    end
  end

  test 'reordering plans' do
    service = Factory(:simple_service)

    free = Factory(:application_plan, :issuer => service)
    basic = Factory(:application_plan, :issuer => service)
    pro = Factory(:application_plan, :issuer => service)

    service.reorder_plans([free.id, basic.id, pro.id])
    [free, basic, pro].map(&:reload)

    assert free.position < basic.position
    assert basic.position < pro.position

    service.reorder_plans([pro.id, basic.id, free.id])
    [free, basic, pro].map(&:reload)

    assert pro.position < basic.position
    assert basic.position < free.position
  end

  context "support_email" do
    should 'fallback to account.support_email' do
      service = Factory(:simple_service)
      service.account.update_attribute :support_email, "support@accounts-table.example.net"
      assert_equal service.support_email, service.account.support_email

      service.update_attribute :support_email, "support@services-table.example.net"
      assert_equal service.support_email, "support@services-table.example.net"
    end

    should "be validated by email format" do
      service = Factory.build(:simple_service, :support_email => "invalid email")
      service.valid?
      assert service.errors[:support_email].present?
    end
  end # support_email

  context '#update_backend_service' do
    setup do
      @service = Service.new
      @service.stubs(:id).returns(5)
      @service.account = Account.new
      @service.account.stubs(:has_bought_cinstance?).returns(true)
      @service.account.stubs(:api_key).returns('provider key')
      @service.account.stubs(:default_service_id).returns(5)
    end

    should 'use Core::Service.save! to pass data to backend' do
      ThreeScale::Core::Service.expects(:save!)

      @service.update_backend_service
    end

    should 'pass the options hash' do
      ThreeScale::Core::Service.expects(:save!).with do |params|
        assert_equal 'provider key', params[:provider_key]
        assert params[:default_service]
      end

      @service.update_backend_service
    end
  end

  def test_accessible_scope
    service = FactoryGirl.create(:simple_service)
    assert_includes Service.accessible.to_a, service

    service.update_column :state, 'deleted'
    refute_includes Service.accessible.to_a, service
  end

  test 'last_accessible?' do
    service = FactoryGirl.create(:simple_service)
    account = service.account

    assert service.last_accessible?

    service2 = FactoryGirl.create(:simple_service, account: account)
    refute service.last_accessible?

    service2.update_column :state, 'deleted'
    assert service.last_accessible?
  end

  test 'Deleting services allowed until the last one' do
    service1 = FactoryGirl.create(:simple_service)
    account = service1.account
    service2 = FactoryGirl.create(:simple_service, account: account)
    refute service1.last_accessible?
    refute service2.last_accessible?

    service1.mark_as_deleted!
    assert service2.last_accessible?
    assert_nil account.default_service_id
  end

  test 'default service cannot be marked as deleted' do
    service = FactoryGirl.create(:simple_service)

    assert service.last_accessible?
    service.stubs(default?: true)

    assert_raise StateMachines::InvalidTransition do
      service.mark_as_deleted!
    end
  end

  test 'last accessible service cannot be marked as deleted' do
    service = FactoryGirl.create(:simple_service)

    service.stubs(last_accessible?: true)

    assert_raise StateMachines::InvalidTransition do
      service.mark_as_deleted!
    end
  end

  test 'destroying service with customized plan' do
   service = FactoryGirl.create(:simple_service)
   service1 = FactoryGirl.create(:simple_service, account: service.account)
   application_plan = FactoryGirl.create(:simple_application_plan, service: service)
   custom_application_plan = application_plan.customize
   custom_application_plan.save!

    assert service.destroy
  end

  class AsynchronousDeletionOfService < ActiveSupport::TestCase
    disable_transactional_fixtures!

    test 'schedule destruction of a service' do
      service = FactoryGirl.create(:simple_service)
      service.stubs(last_accessible?: false)
      Services::ServiceScheduledForDeletionEvent.expects(:create_and_publish!).with(service).once
      System::ErrorReporting.expects(:report_error).never
      service.mark_as_deleted!
    end

    test 'updating state without using state machine' do
      service = FactoryGirl.create(:simple_service)
      service.stubs(last_accessible?: false)
      Services::ServiceScheduledForDeletionEvent.expects(:create_and_publish!).never
      System::ErrorReporting.expects(:report_error).once
      service.update_attributes(state: 'deleted')
    end
  end

  test 'don not call update endpoint if deployment option has not changed' do
    service = FactoryGirl.create(:simple_service, deployment_option: 'hosted')
    service.expects(:deployment_option_changed).times(0)
    service.update(deployment_option: 'hosted')
  end

  test 'call update endpoint on proxy after update when deployment option has changed' do
    service = FactoryGirl.create(:simple_service, deployment_option: 'hosted')

    Proxy.any_instance.expects(:set_correct_endpoints).never
    service.update(deployment_option: service.deployment_option)

    Proxy.any_instance.expects(:set_correct_endpoints).once
    service.update(deployment_option: 'self_managed')
  end

  test 'is proxy pro actually being used?' do
    service = Service.new(account: account = Account.new)
    service.proxy = Proxy.new(service: service)

    account.stubs(:provider_can_use?).with(:apicast_v1).returns(true) # irrelevant for this test
    account.stubs(:provider_can_use?).with(:apicast_v2).returns(true) # irrelevant for this test

    account.stubs(:provider_can_use?).with(:proxy_pro).returns(false)
    refute service.using_proxy_pro?

    account.stubs(:provider_can_use?).with(:proxy_pro).returns(true)

    service.deployment_option = 'self_managed'
    assert service.using_proxy_pro?

    service.deployment_option = 'hosted'
    refute service.using_proxy_pro?
  end

  test 'of_approved_account' do
    account = FactoryGirl.create(:simple_provider, state: 'suspended')
    service = FactoryGirl.create(:simple_service, account: account)
    assert_not_includes Service.of_approved_accounts, service
  end

  test 'create with backend_version oidc' do
    account = FactoryGirl.create(:simple_provider)
    service_params = {backend_version: 'oidc', name: 'test', deployment_option: 'self_managed'}
    service = account.create_service(service_params)

    assert service.persisted?
  end

  test '.permitted_for_user' do
    FactoryGirl.create_list(:simple_service, 2)
    user = User.new
    member_permission_service_ids = [Service.last.id]
    user.stubs(member_permission_service_ids: member_permission_service_ids)

    user.stubs(forbidden_some_services?: false)
    assert_same_elements Service.pluck(:id), Service.permitted_for_user(user).pluck(:id)

    user.stubs(forbidden_some_services?: true)
    assert_same_elements member_permission_service_ids, Service.permitted_for_user(user).pluck(:id)
  end
end
