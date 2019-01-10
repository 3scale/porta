# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class CreateServiceWorkerTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.service_discovery.stubs(enabled: true)
      @user = nil
    end

    test 'perform' do
      oauth_manager = mock(service_usable?: true)
      account = FactoryBot.create(:simple_provider)
      ServiceDiscovery::OAuthManager.expects(:new).with(@user).returns(oauth_manager).at_least_once
      import_definition = mock
      import_definition.expects(:create_service).with(account, cluster_namespace: 'fake-project', cluster_service_name: 'fake-api')
      ImportClusterDefinitionsService.expects(:new).with(@user).returns(import_definition)
      CreateServiceWorker.new.perform(account.id, 'fake-project', 'fake-api', @user&.id)
    end
  end

  class CreateServiceWorkerWithUserTest < CreateServiceWorkerTest
    def setup
      super
      @user = FactoryBot.create(:simple_user)
    end
  end
end
