# frozen_string_literal: true

require 'test_helper'

module DataMigrations
  class CreateBackendApisTest < DataMigrationTest
    setup do
      @migration = CreateBackendApis.new
    end

    attr_reader :migration

    test "creates backend api for services that don't have one" do
      provider = FactoryBot.create(:simple_provider)
      services = FactoryBot.create_list(:simple_service, 7, account: provider)
      services.each { |service| service.proxy.update_column(:api_backend, 'https://api.example.com') }

      # 1st service already has backend api
      services.first.backend_api_configs.create(backend_api: FactoryBot.create(:backend_api, account: provider), path: '/')

      # 2nd and 3rd services don't have backend_api but neither their proxy have a private_endpoint
      services[1..2].each { |service| service.proxy.update_column(:api_backend, nil) }

      assert_change of: ->{ provider.backend_apis.count }, by: 4 do
        migration.up
      end
    end

    test 'it does nothing when all services already have backend api config' do
      $stdout.expects(:puts).with('Nothing to do.')
      refute migration.up
    end
  end
end
