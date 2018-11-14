# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class RefreshServiceWorkerTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.service_discovery.stubs(enabled: true)
      @user = nil
    end

    test 'perform' do
      oauth_manager = mock(service_usable?: true)
      ServiceDiscovery::OAuthManager.expects(:new).with(@user).returns(oauth_manager).at_least_once
      service = FactoryGirl.create(:simple_service)
      import_definition = mock
      import_definition.expects(:refresh_service).with(service)
      ImportClusterDefinitionsService.expects(:new).with(@user).returns(import_definition)
      RefreshServiceWorker.new.perform(service.id, @user&.id)
    end
  end

  class RefreshServiceWorkerWithAUser < RefreshServiceWorkerTest
    def setup
      super
      @user = FactoryGirl.create(:simple_user)
    end
  end
end
