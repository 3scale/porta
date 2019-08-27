# frozen_string_literal: true

require 'test_helper'

class DestroyAllDeletedObjectsWorkerTest < ActiveSupport::TestCase

  class DestroyingService < DestroyAllDeletedObjectsWorkerTest
    test 'perform destroys message recipient' do
      message = FactoryBot.create(:received_message, deleted_at: DateTime.yesterday)
      Sidekiq::Testing.inline! do
        assert_difference(MessageRecipient.method(:count), -1) do
          DestroyAllDeletedObjectsWorker.perform_async('MessageRecipient')
        end
        assert_raise(ActiveRecord::RecordNotFound) { message.reload }
      end
    end

    test 'perform enqueues delete object hierarchy worker jobs' do
      provider = FactoryBot.create(:simple_provider)
      services = FactoryBot.create_list(:simple_service, 2, account: provider)
      services.first.mark_as_deleted!

      DeleteObjectHierarchyWorker.expects(:perform_later).once.with do |object, _hierarchy|
        object.id == services.first.id
      end

      Sidekiq::Testing.inline! do
        DestroyAllDeletedObjectsWorker.perform_async(Service.to_s)
      end
    end
  end

  class DestroyingBackendApi < DestroyAllDeletedObjectsWorkerTest
    test 'perform destroys all oprhans backend apis' do
      backend_api = FactoryBot.create(:backend_api_config).backend_api
      orphan_backend_api = FactoryBot.create(:backend_api_config).backend_api
      orphan_backend_api.services.destroy_all

      Sidekiq::Testing.inline! do
        assert_difference(BackendApi.method(:count), -1) do
          DestroyAllDeletedObjectsWorker.perform_async('BackendApi', :orphans)
        end
        assert_raise(ActiveRecord::RecordNotFound) { orphan_backend_api.reload }
      end
    end
  end
end
