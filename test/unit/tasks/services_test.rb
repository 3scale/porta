# frozen_string_literal: true

require 'test_helper'

module Tasks
  class ServicesTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'destroy_marked_as_deleted' do
      DestroyAllDeletedObjectsWorker.expects(:perform_later).once.with('Service')

      execute_rake_task 'services.rake', 'services:destroy_marked_as_deleted'
    end

    test 'destroy_service removes the default service in Porta and Apisonator' do
      default_service = FactoryBot.create(:simple_service)
      account = default_service.account
      another_service = FactoryBot.create(:simple_service, account: account)
      account.update!({default_service_id: default_service.id}, without_protection: true)
      default_service.reload

      ThreeScale::Core::Service.expects(:make_default).with(another_service.backend_id)
      ThinkingSphinx::Test.disable_real_time_callbacks!
      assert_difference(EventStore::Repository.adapter.where(event_type: Services::ServiceDeletedEvent.to_s).method(:count)) do
        perform_enqueued_jobs do
          execute_rake_task 'services.rake', 'services:destroy_service', account.id, default_service.id
        end
      end

      refute Service.where(id: default_service.id).exists?
      assert_equal another_service.id, account.reload.default_service_id

      event = EventStore::Repository.adapter.where(event_type: Services::ServiceDeletedEvent.to_s).last!
      assert_equal event.data[:service_id], default_service.id
    end

    test 'destroy_service raises ActiveRecord::RecordNotFound or StateMachines::InvalidTransition when the Account does not have another active Service' do
      default_service = FactoryBot.create(:simple_service)
      default_service.account.update!({default_service_id: default_service.id}, without_protection: true)
      non_default_service = FactoryBot.create(:simple_service)
      non_default_service.account.update!({default_service_id: nil}, without_protection: true)

      assert_raise(ActiveRecord::RecordNotFound) do
        execute_rake_task 'services.rake', 'services:destroy_service', default_service.account.id, default_service.id
      end

      assert_raise(StateMachines::InvalidTransition) do
        execute_rake_task 'services.rake', 'services:destroy_service', non_default_service.account.id, non_default_service.id
      end
    end

    test 'destroy_service raises ActiveRecord::RecordNotFound when the Service does not belong to the Account' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create(:simple_service, account: service.account)
      another_account = FactoryBot.create(:simple_account)

      assert_raise(ActiveRecord::RecordNotFound) do
        execute_rake_task 'services.rake', 'services:destroy_service', another_account.id, service.id
      end
    end

    test 'destroy_service removes the non-default Service in Porta and Apisonator' do
      default_service = FactoryBot.create(:simple_service)
      account = default_service.account
      non_default_service = FactoryBot.create(:simple_service, account: account)
      account.update!({default_service_id: default_service.id}, without_protection: true)
      default_service.reload

      ThreeScale::Core::Service.expects(:make_default).never
      ThreeScale::Core::Service.expects(:save!).never

      assert_difference(EventStore::Repository.adapter.where(event_type: Services::ServiceDeletedEvent.to_s).method(:count)) do
        perform_enqueued_jobs(except: SphinxIndexationWorker) do
          execute_rake_task 'services.rake', 'services:destroy_service', account.id, non_default_service.id
        end
      end

      refute Service.where(id: non_default_service.id).exists?
      assert_equal default_service.id, account.reload.default_service_id

      event = EventStore::Repository.adapter.where(event_type: Services::ServiceDeletedEvent.to_s).last!
      assert_equal event.data[:service_id], non_default_service.id
    end
  end
end
