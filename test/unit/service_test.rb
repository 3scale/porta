# frozen_string_literal: true

require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  test '#accessible?' do
    service = Service.new

    Service.state_machine.states.each do |state|
      service.state = state.name.to_s

      if service.state == Service::DELETE_STATE
        assert_not service.accessible?
      else
        assert service.accessible?
      end
    end
  end

  test 'create default proxy' do
    Service.any_instance.expects(:create_proxy!).at_least_once
    FactoryBot.create(:simple_service, proxy: nil)

    Service.any_instance.expects(:create_proxy!).never
    service = FactoryBot.create(:simple_service, proxy: FactoryBot.build(:proxy))
    assert_not_nil service.proxy
  end

  test 'create with default private endpoint' do
    account = FactoryBot.build(:provider_account)
    account.save!
    service = account.default_service
    assert_equal BackendApi.default_api_backend, service.api_backend
  end

  test 'backend_version=' do
    service = FactoryBot.build_stubbed(:simple_service)
    service.backend_version = 'oauth'
    assert_equal 'oauth', service.backend_version
    assert_equal 'oauth', service.proxy.authentication_method

    service.backend_version = 'oidc'
    assert_equal 'oauth', service.backend_version
    assert_equal 'oidc', service.proxy.authentication_method
  end

  test 'parameterized system_name' do
    service = Service.new(system_name: 'api_2')

    assert_equal 'api-2', service.parameterized_system_name
  end

  # Backward compatibility with providers that still have default service.
  # It cannot be deleted in backend that is why we need this
  test 'stop destroy if last default' do
    service = FactoryBot.create(:simple_service)

    service.expects(:default?).returns(true)
    service.destroy
    assert service.reload

    service.expects(:destroyed_by_association).returns(Account.new)
    service.destroy
    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end

  test 'create with plugin' do
    service = FactoryBot.build(:simple_service, deployment_option: 'plugin_rest', account: FactoryBot.create(:simple_account))

    assert service.save!
  end

  test 'deployment_option=' do
    FactoryBot.create(:simple_service, deployment_option: 'self_managed')

    service = Service.last!
    service.update!(deployment_option: 'hosted')

    proxy = service.proxy

    assert_predicate proxy, :valid?
    assert_predicate proxy, :persisted?

    assert proxy.production_endpoint
    assert proxy.staging_endpoint
  end

  test 'deployment_options' do
    deployment_options = Service.deployment_options

    assert_includes deployment_options, 'Gateway'
    assert_includes deployment_options, 'Plugin'
    assert_includes deployment_options, 'Service Mesh'
  end

  # Now the last remaining service cannot be destroyed
  test 'stop destroy if last' do
    service = FactoryBot.create(:simple_service)

    service.expects(:last_accessible?).returns(true)
    service.destroy
    assert service.reload

    service.expects(:destroyed_by_association).returns(Account.new)
    service.destroy
    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
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
    account = FactoryBot.create(:simple_account)
    service = Service.new do |s|
      s.account = account
      s.system_name = 'foo'
    end
    service.save(validate: false)

    assert_not service.service_token

    service.service_tokens.create!(value: 'foobar')

    assert_equal 'foobar', service.service_token
  end

  test 'has friendly human attribute names' do
    assert_equal 'URL', Service.human_attribute_name('friendly_id')
  end

  test 'should be in incomplete state' do
    @service = Service.create!(account: FactoryBot.create(:simple_provider), name: 'PandaCam')
    assert @service.incomplete?
  end

  test 'should have default metrics' do
    @service = Service.create!(account: FactoryBot.create(:simple_provider), name: 'PandaCam')
    assert_not_nil @service.metrics.first
    assert_equal 'hits', @service.metrics.first.name
  end

  test 'alert_limits' do
    service = FactoryBot.create(:simple_service)
    ThreeScale::Core::AlertLimit.expects(:load_all).with(service.backend_id).returns([])
    service.send(:alert_limits)
  end

  test 'delete_alert_limits' do
    service = FactoryBot.create(:simple_service)
    ThreeScale::Core::AlertLimit.expects(:delete).with(service.backend_id, :foo)
    service.send(:delete_alert_limits, :foo)
  end

  test 'create_alert_limits' do
    service = FactoryBot.create(:simple_service)
    ThreeScale::Core::AlertLimit.expects(:save).with(service.backend_id, :foo)
    service.send(:create_alert_limits, :foo)
  end

  test 'Service#cinstances returns cinstances of plans of the service' do
    service = FactoryBot.create(:simple_service)
    plan = FactoryBot.create(:application_plan, issuer: service)
    buyer_account = FactoryBot.create(:simple_buyer)

    cinstance = buyer_account.buy!(plan)
    assert_contains service.cinstances, cinstance
  end

  test '#has_traffic?' do
    service = FactoryBot.create(:simple_service)
    plan = FactoryBot.create(:application_plan, issuer: service)

    buyer1 = FactoryBot.create(:simple_buyer)
    buyer2 = FactoryBot.create(:simple_buyer)

    app1 = buyer1.buy!(plan)
    buyer2.buy!(plan)

    assert_equal false, service.has_traffic?

    app1.update(first_traffic_at: Time.zone.now)
    assert_equal true, service.has_traffic?
  end

  test '#mode_type' do
    assert_nil Service.new.mode_type

    service = FactoryBot.create(:simple_service)

    service.assign_attributes(deployment_option: 'hosted', backend_version: '1')
    assert_equal :hosted, service.mode_type

    service.assign_attributes(deployment_option: 'self_managed', backend_version: '1')
    assert_equal :self_managed, service.mode_type

    service.assign_attributes(deployment_option: 'self_managed', backend_version: 'oauth')
    assert_equal :oauth, service.mode_type
  end

  test 'Service#cinstances does not return destroyed cinstances' do
    service = FactoryBot.create(:simple_service)
    plan = FactoryBot.create(:application_plan, issuer: service)
    buyer_account = FactoryBot.create(:simple_buyer)

    cinstance = buyer_account.buy!(plan)
    cinstance.destroy

    assert_does_not_contain service.cinstances, cinstance
  end

  test 'Service#cinstances returns read-write cinstances' do
    service = FactoryBot.create(:simple_service)
    plan = FactoryBot.create(:application_plan, issuer: service)
    buyer_account = FactoryBot.create(:simple_buyer)

    buyer_account.buy!(plan)

    assert_not service.cinstances.first.readonly?
  end

  test '#has_method_metrics? should return true if metric hits has children' do
    service = FactoryBot.create(:simple_service)
    metric = service.metrics.first
    metric.children.create!(system_name: 'foos', friendly_name: 'Foos')
    assert service.has_method_metrics?
  end

  test '#has_method_metrics? should return false if metric hits does not have children' do
    service = FactoryBot.create(:simple_service)
    assert_not service.has_method_metrics?
  end

  test '#method_metrics should return only metrics that are children of hits' do
    service = FactoryBot.create(:simple_service)
    hits = service.metrics.hits!
    method1 = hits.children.create!(friendly_name: 'Foos')
    method2 = hits.children.create!(friendly_name: 'Bars')

    assert_equal 'foos', method1.system_name

    FactoryBot.create(:metric, owner: service)

    assert_same_elements [method1, method2], service.method_metrics
  end

  test '#method_metrics should return null relation if service has no methods defined' do
    service = FactoryBot.create(:simple_service)
    assert_equal Metric.none, service.method_metrics
  end

  test "default service cannot be destroyed" do
    provider = FactoryBot.create(:provider_account)
    service = provider.default_service

    service.destroy
    assert service.reload
    assert service.errors.present?
  end

  test '#plugin_deployment? returns true when using a plugin as deployment option' do
    service = FactoryBot.build(:service, deployment_option: 'plugin_ruby')
    assert service.plugin_deployment?

    service = FactoryBot.build(:service, deployment_option: 'hosted')
    assert_not service.plugin_deployment?
  end

  test 'default service plan' do
    service = FactoryBot.build(:simple_service)
    service.account.settings.service_plans_ui_visible = true

    service.save!

    service_plan = service.service_plans.first!
    assert_equal 'hidden', service_plan.state
  end

  test 'default published service plan' do
    Logic::RollingUpdates.stubs(skipped?: true)

    service = FactoryBot.build(:simple_service)
    service.account.settings.service_plans_ui_visible = false

    service.save!

    service_plan = service.service_plans.first!
    assert_equal 'hidden', service_plan.state
  end

  test 'default published service plan with rolling update' do
    Logic::RollingUpdates.stubs(enabled?: true, skipped?: false)

    service = FactoryBot.build(:simple_service)
    service.account.settings.service_plans_ui_visible = false

    Logic::RollingUpdates.feature(:published_service_plan_signup).any_instance.expects(:missing_config).returns(true)
    service.save!

    service_plan = service.service_plans.first!
    assert_equal 'published', service_plan.state
  end

  class DestroyingServiceTest < ActiveSupport::TestCase
    test "destroying service destroys it's plans" do
      service = FactoryBot.create(:service)
      service_plan = FactoryBot.create(:application_plan, issuer: service)
      application_plan = FactoryBot.create(:service_plan, issuer: service)

      service.destroy

      assert_raise(ActiveRecord::RecordNotFound) { application_plan.reload }
      assert_raise(ActiveRecord::RecordNotFound) { service_plan.reload }
    end

    test "destroying service destroys it's features" do
      service = FactoryBot.create(:service)
      feature = FactoryBot.create(:feature, featurable: service)

      service.destroy

      assert_nil Feature.find_by(id: feature.id)
    end

    test "destroying service destroys it's metrics" do
      service = FactoryBot.create(:service)
      metric  = FactoryBot.create(:metric, owner: service)

      service.destroy

      assert_nil Metric.find_by(id: metric.id)
    end

    test 'destroying service creates a related event' do
      service = FactoryBot.create(:simple_service)
      service.stubs(destroyed_by_association: true)
      service_id = service.id
      assert_difference(RailsEventStoreActiveRecord::Event.where(event_type: Services::ServiceDeletedEvent.to_s).method(:count)) do
        service.destroy!
      end
      event = RailsEventStoreActiveRecord::Event.where(event_type: Services::ServiceDeletedEvent.to_s).last!
      assert_equal service_id, event.data['service_id']
    end
  end

  class CreateServiceTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    test 'creating service creates a related event' do
      User.stubs(current: FactoryBot.create(:simple_user))
      assert_difference(RailsEventStoreActiveRecord::Event.where(event_type: Services::ServiceCreatedEvent.to_s).method(:count)) do
        FactoryBot.create(:simple_service)
      end
    end
  end

  class DestroyServiceTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    test 'archive as deleted' do
      account = FactoryBot.create(:simple_provider)
      service = FactoryBot.create(:simple_service, account: account)
      FactoryBot.create(:simple_service, account: account) # To be able to destroy the other service

      assert_difference(DeletedObject.where(object_type: Service.to_s).method(:count), +1) { service.destroy! }
      deleted_object_entry = DeletedObject.where(object_type: Service.to_s).last!
      assert_equal service.id, deleted_object_entry.object_id
      assert_equal 'Service', deleted_object_entry.object_type
      assert_equal account.id, deleted_object_entry.owner_id
      assert_equal 'Account', deleted_object_entry.owner_type
    end
  end

  test 'support_email should fallback to account.support_email' do
    service = FactoryBot.create(:simple_service)
    service.account.update(support_email: "support@accounts-table.example.net")
    assert_equal service.support_email, service.account.support_email

    service.update(support_email: "support@services-table.example.net")
    assert_equal service.support_email, "support@services-table.example.net"
  end

  test "support_email should be validated by email format" do
    service = FactoryBot.build(:simple_service, support_email: "invalid email")
    service.valid?
    assert service.errors[:support_email].present?
  end

  test '#update_backend_service should use Core::Service.save! to pass data to backend' do
    service = FactoryBot.create(:simple_service)
    service.stubs(:id).returns(5)
    service.account.stubs(:has_bought_cinstance?).returns(true)
    service.account.stubs(:api_key).returns('provider key')
    service.account.stubs(:default_service_id).returns(5)

    ThreeScale::Core::Service.expects(:save!)
    service.update_backend_service
  end

  test '#update_backend_service should pass the options hash' do
    service = FactoryBot.create(:simple_service)
    service.stubs(:id).returns(5)
    service.account.stubs(:has_bought_cinstance?).returns(true)
    service.account.stubs(:api_key).returns('provider key')
    service.account.stubs(:default_service_id).returns(5)

    ThreeScale::Core::Service.expects(:save!).with do |params|
      assert_equal 'provider key', params[:provider_key]
      assert params[:default_service]
    end

    service.update_backend_service
  end

  def test_accessible_scope
    service = FactoryBot.create(:simple_service)
    assert_includes Service.accessible.to_a, service

    service.update(state: 'deleted')
    assert_not_includes Service.accessible.to_a, service
  end

  test 'last_accessible?' do
    service = FactoryBot.create(:simple_service)
    account = service.account

    assert service.last_accessible?

    service2 = FactoryBot.create(:simple_service, account: account)
    assert_not service.last_accessible?

    service2.update(state: 'deleted')
    assert service.last_accessible?
  end

  test 'Deleting services allowed until the last one' do
    service1 = FactoryBot.create(:simple_service)
    account = service1.account
    service2 = FactoryBot.create(:simple_service, account: account)
    assert_not service1.last_accessible?
    assert_not service2.last_accessible?

    service1.mark_as_deleted!
    assert service2.last_accessible?
    assert_nil account.default_service_id
  end

  test 'default service cannot be marked as deleted' do
    service = FactoryBot.create(:simple_service)

    assert service.last_accessible?
    service.stubs(default?: true)

    assert_raise StateMachines::InvalidTransition do
      service.mark_as_deleted!
    end
  end

  test 'last accessible service cannot be marked as deleted' do
    service = FactoryBot.create(:simple_service)

    service.stubs(last_accessible?: true)

    assert_raise StateMachines::InvalidTransition do
      service.mark_as_deleted!
    end
  end

  test 'destroying service with customized plan' do
    service = FactoryBot.create(:simple_service)
    FactoryBot.create(:simple_service, account: service.account)
    application_plan = FactoryBot.create(:simple_application_plan, service: service)
    custom_application_plan = application_plan.customize
    custom_application_plan.save!

    assert service.destroy
  end

  class AsynchronousDeletionOfService < ActiveSupport::TestCase
    test 'schedule destruction of a service' do
      service = FactoryBot.create(:simple_service)
      service.stubs(last_accessible?: false)
      Services::ServiceScheduledForDeletionEvent.expects(:create_and_publish!).with(service).once
      System::ErrorReporting.expects(:report_error).never
      service.mark_as_deleted!
    end

    test 'updating state without using state machine' do
      service = FactoryBot.create(:simple_service)
      service.stubs(last_accessible?: false)
      Services::ServiceScheduledForDeletionEvent.expects(:create_and_publish!).never
      System::ErrorReporting.expects(:report_error).once
      service.update(state: 'deleted')
    end
  end

  test 'call update endpoint on proxy after update when deployment option has changed' do
    service = FactoryBot.create(:simple_service, deployment_option: 'hosted')

    Proxy.any_instance.expects(:set_correct_endpoints).never
    service.update(deployment_option: service.deployment_option)

    Proxy.any_instance.expects(:set_correct_endpoints).once
    service.update(deployment_option: 'self_managed')
  end

  test 'is proxy pro actually being used?' do
    service = Service.new(account: account = Account.new)
    service.proxy = Proxy.new(service: service)

    account.stubs(:provider_can_use?).with(:apicast_v2).returns(true) # irrelevant for this test

    account.stubs(:provider_can_use?).with(:proxy_pro).returns(false)
    assert_not service.using_proxy_pro?

    account.stubs(:provider_can_use?).with(:proxy_pro).returns(true)

    service.deployment_option = 'self_managed'
    assert service.using_proxy_pro?

    service.deployment_option = 'hosted'
    assert_not service.using_proxy_pro?
  end

  test 'of_approved_account' do
    account = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:simple_service, account: account)
    account.suspend!
    assert_not_includes Service.of_approved_accounts, service
  end

  test 'create with backend_version oidc' do
    account = FactoryBot.create(:simple_provider)
    service_params = { backend_version: 'oidc', name: 'test', deployment_option: 'self_managed' }
    service = account.create_service(service_params)

    assert service.persisted?
  end

  test '.permitted_for' do
    account = FactoryBot.create(:simple_provider)
    FactoryBot.create_list(:simple_service, 2, account: account)
    user = FactoryBot.create(:member, account: account)
    member_permission_service_ids = [Service.last.id]
    user.stubs(member_permission_service_ids: member_permission_service_ids)

    user.stubs(permitted_services_status: :all)
    assert_same_elements account.services.pluck(:id), Service.permitted_for(user).pluck(:id)

    user.stubs(permitted_services_status: :selected)
    assert_same_elements member_permission_service_ids, Service.permitted_for(user).pluck(:id)
    assert_same_elements Service.pluck(:id), Service.permitted_for.pluck(:id)
  end


  test 'oidc_configuration' do
    service = Service.new

    proxy = Proxy.new
    config = OIDCConfiguration.new
    service.stubs(proxy: proxy)
    proxy.expects(oidc_configuration: config)

    assert_equal config, service.oidc_configuration

    service.stubs(proxy: nil)
    assert_instance_of(OIDCConfiguration, service.oidc_configuration)
  end

  class DeploymentOptionTest < ActiveSupport::TestCase
    def test_all
      all = Service::DeploymentOption.all

      assert_includes all, 'plugin_ruby'
      assert_includes all, 'self_managed'
      assert_includes all, 'service_mesh_istio'
    end

    def test_service_mesh
      service_mesh = Service::DeploymentOption.service_mesh

      assert_includes service_mesh, 'service_mesh_istio'
      assert_not_includes service_mesh, 'plugin_ruby'
      assert_not_includes service_mesh, 'hosted'
    end

    def test_gateways
      gateways = Service::DeploymentOption.gateways

      assert_includes gateways, 'self_managed'
      assert_includes gateways, 'hosted'
      assert_not_includes gateways, 'plugin_ruby'
      assert_not_includes gateways, 'service_mesh_istio'
    end

    def test_gateways_with_apicast_custom_url
      ThreeScale.config.stubs(apicast_custom_url: true)
      gateways = Service::DeploymentOption.gateways

      assert_includes gateways, 'self_managed'
      assert_includes gateways, 'hosted'
      assert_not_includes gateways, 'plugin_ruby'
      assert_not_includes gateways, 'service_mesh_istio'
    end

    def test_plugins
      plugins = Service::DeploymentOption.plugins

      assert_not_includes plugins, 'self_managed'
      assert_not_includes plugins, 'hosted'
      assert_includes plugins, 'plugin_ruby'
    end
  end

  class ProxyConfigAffectingChangesTest < ActiveSupport::TestCase
    test 'does not track changes on build' do
      with_proxy_config_affecting_changes_tracker do |tracker|
        service = FactoryBot.build(:simple_service) # backend_version not touched
        assert_not tracker.tracking?(ProxyConfigAffectingChanges::TrackedObject.new(service))
      end
    end

    test 'tracks changes on backend_version' do
      with_proxy_config_affecting_changes_tracker do |tracker|
        service = FactoryBot.create(:simple_service)
        tracker.flush

        service.expects(:track_proxy_affecting_changes).never
        service.update(name: 'new name')

        service.expects(:track_proxy_affecting_changes).once
        service.update(backend_version: 'oauth')
      end
    end

    test 'tracks changes on destroy' do
      with_proxy_config_affecting_changes_tracker do |tracker|
        service = FactoryBot.create(:simple_service)
        tracker.flush

        service.expects(:track_proxy_affecting_changes).once
        service.destroy
      end
    end
  end
end
