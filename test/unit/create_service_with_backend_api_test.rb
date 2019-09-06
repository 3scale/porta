require 'test_helper'

class CreateServiceWithBackendApiTest < ActiveSupport::TestCase
  test 'should not create any backend api if backend_api is not sent' do
    backend_api    = nil
    account        = stub(provider_can_use?: true)
    service        = FactoryBot.build(:service)
    create_service = CreateServiceWithBackendApi.new(service: service, account: account, backend_api: backend_api)

    assert_change of: -> { BackendApi.count }, by: 0 do
      saved = create_service.call

      assert saved
    end
  end

  test 'should create the default backend api if backend_api option is set as new' do
    backend_api    = 'new'
    account        = stub(provider_can_use?: true)
    service        = FactoryBot.build(:service)
    create_service = CreateServiceWithBackendApi.new(service: service, account: account, backend_api: backend_api)

    assert_change of: -> { BackendApi.count }, by: 1 do
      saved = create_service.call

      assert saved
    end
  end

  test 'should associate the same backend api if backend_api option is an id and it belongs to the same account' do
    account        = FactoryBot.create(:account)
    backend_api    = FactoryBot.create(:backend_api, account: account)
    service        = FactoryBot.build(:service, account: account)
    create_service = CreateServiceWithBackendApi.new(service: service, account: account, backend_api: backend_api.id)

    assert_change of: -> { BackendApi.count }, by: 0 do
      saved = create_service.call

      assert saved
      assert_equal backend_api, Service.last.backend_api
    end
  end

  test 'should raise an error if trying to associate a backend api that belongs to another account' do
    account         = FactoryBot.create(:account)
    another_account = FactoryBot.create(:account)
    backend_api     = FactoryBot.create(:backend_api, account: another_account)
    service         = FactoryBot.build(:service, account: account)
    create_service  = CreateServiceWithBackendApi.new(service: service, account: account, backend_api: backend_api.id)

    assert_raise(ActiveRecord::RecordNotFound) do
      create_service.call
    end
  end

  test 'should not create the backend api if account is not in the rolling update' do
    backend_api    = 'new'
    service        = FactoryBot.build(:service)
    account        = stub(provider_can_use?: false)
    create_service = CreateServiceWithBackendApi.new(service: service, account: account, backend_api: backend_api)

    assert_change of: -> { BackendApi.count }, by: 0 do
      saved = create_service.call

      assert saved
      assert_nil Service.last.backend_api
    end
  end
end
