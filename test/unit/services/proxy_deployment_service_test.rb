# frozen_string_literal: true

require 'test_helper'

class ProxyDeploymentServiceTest < ActiveSupport::TestCase
  def setup
    @proxy = FactoryBot.create(:simple_proxy, api_backend: nil)
  end

  test 'deploy when apicast_configuration_driven' do
    @proxy.expects(:service_mesh_integration?).returns(false)
    @proxy.expects(:apicast_configuration_driven).returns(true)

    service = ProxyDeploymentService.new(@proxy)
    service.expects(:deploy_v2).returns(true)

    assert service.call
  end

  test 'deploy with service mesh integration' do
    @proxy.expects(:service_mesh_integration?).returns(true)
    @proxy.expects(:apicast_configuration_driven).never

    service = ProxyDeploymentService.new(@proxy)
    service.expects(:deploy_v2).returns(true)
    service.expects(:deploy_production_v2).returns(true)

    assert service.call
  end

  test 'deploy production if apicast configuration driven' do
    @proxy.expects(:apicast_configuration_driven).returns(true)

    service = ProxyDeploymentService.new(@proxy, environment: :production)
    service.expects(:deploy_v2).never
    service.expects(:deploy_production_v2).returns(true)

    assert service.call
  end

  test 'deploy production not apicast configuration driven but api test success' do
    @proxy.expects(:apicast_configuration_driven).returns(false)
    @proxy.expects(:api_test_success).returns(true)

    service = ProxyDeploymentService.new(@proxy, environment: :production)
    service.expects(:deploy_v2).never
    service.expects(:deploy_production_v2).never

    @proxy.provider.expects(:deploy_production_apicast).returns(true)

    assert service.call
  end

  test 'deploy neither service mesh or apicast configuration driven' do
    @proxy.expects(:service_mesh_integration?).returns(false)
    @proxy.expects(:apicast_configuration_driven).returns(false)

    service = ProxyDeploymentService.new(@proxy)
    service.expects(:deploy_v2).never
    service.expects(:deploy_v1).never # Deprecated

    refute service.call
  end

  # Deprecated
  test 'deploy neither service mesh or apicast configuration driven but v1 compatible' do
    @proxy.expects(:service_mesh_integration?).returns(false)
    @proxy.expects(:apicast_configuration_driven).returns(false)

    service = ProxyDeploymentService.new(@proxy, v1_compatible: true)
    service.expects(:deploy_v2).never
    service.expects(:deploy_v1).returns(true).once

    assert service.call
  end

  test 'deploy to unknown stage should raise' do
    assert_raise ProxyDeploymentService::UnknownStageError do
      ProxyDeploymentService.call(@proxy, environment: :false_stage)
    end
  end

  test 'deploy when not deployable' do
    @proxy.expects(:deployable?).returns(false)

    assert ProxyDeploymentService.call(@proxy)
  end

  test 'deploy when deployable' do
    @proxy.expects(:deployable?).returns(true)

    assert ProxyDeploymentService.call(@proxy)
  end
end
