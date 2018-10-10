# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class CreateServiceWorkerTest < ActiveSupport::TestCase
    test 'perform' do
      account = FactoryGirl.create(:simple_provider)
      ImportClusterDefinitionsService.any_instance.expects(:create_service).with(account, cluster_namespace: 'fake-project', cluster_service_name: 'fake-api')
      CreateServiceWorker.new.perform(account.id, 'fake-project', 'fake-api')
    end
  end
end
