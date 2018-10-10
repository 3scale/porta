# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class RefreshServiceWorkerTest < ActiveSupport::TestCase
    test 'perform' do
      service = FactoryGirl.create(:service)
      ImportClusterDefinitionsService.any_instance.expects(:refresh_service).with(service)
      RefreshServiceWorker.new.perform(service.id)
    end
  end
end
