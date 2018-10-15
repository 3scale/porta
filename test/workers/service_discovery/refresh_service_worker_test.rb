# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class RefreshServiceWorkerTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.service_discovery.stubs(enabled: true)
    end

    test 'perform' do
      service = FactoryGirl.create(:service)
      ImportClusterDefinitionsService.any_instance.expects(:refresh_service).with(service)
      RefreshServiceWorker.new.perform(service.id)
    end
  end
end
