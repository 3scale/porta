# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class CreateServiceWorkerTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.service_discovery.stubs(enabled: true)
      @user = nil
    end

    test 'perform' do
      token_retriever = mock(service_usable?: true)
      account = FactoryGirl.create(:simple_provider)
      ServiceDiscovery::TokenRetriever.expects(:new).with(@user).returns(token_retriever).at_least_once
      import_definition = mock
      import_definition.expects(:create_service).with(account, cluster_namespace: 'fake-project', cluster_service_name: 'fake-api')
      ImportClusterDefinitionsService.expects(:new).with(@user).returns(import_definition)
      CreateServiceWorker.new.perform(account.id, 'fake-project', 'fake-api', @user&.id)
    end
  end

  class CreateServiceWorkerWithUserTest < CreateServiceWorkerTest
    def setup
      super
      @user = FactoryGirl.create(:simple_user)
    end
  end
end
