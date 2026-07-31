# frozen_string_literal: true

require 'test_helper'

class DeleteAccountHierarchyWorkerTest < ActiveSupport::TestCase
  attr_reader :provider

  setup do
    @provider = FactoryBot.create(:simple_provider)
  end

  test "is a subclass of DeleteObjectHierarchyWorker" do
    assert DeleteAccountHierarchyWorker < DeleteObjectHierarchyWorker
  end

  test "uses the deletion queue" do
    assert_equal "deletion", DeleteAccountHierarchyWorker.new.queue_name
  end

  test "concurrency_limit defaults to DEFAULT_CONCURRENCY_LIMIT when Redis key is absent" do
    Sidekiq.redis { |c| c.del(DeleteAccountHierarchyWorker::CONCURRENCY_LIMIT_KEY) }
    assert_equal DeleteAccountHierarchyWorker::DEFAULT_CONCURRENCY_LIMIT, DeleteAccountHierarchyWorker.concurrency_limit
  end

  test "concurrency_limit= sets the value in Redis and concurrency_limit reads it back" do
    DeleteAccountHierarchyWorker.concurrency_limit = 7
    assert_equal 7, DeleteAccountHierarchyWorker.concurrency_limit
  ensure
    Sidekiq.redis { |c| c.del(DeleteAccountHierarchyWorker::CONCURRENCY_LIMIT_KEY) }
  end

  test "compatibility hierarchy" do
    whatever_object = provider.default_service
    DeleteObjectHierarchyWorker.expects(:delete_later).with(provider)

    DeleteAccountHierarchyWorker.perform_now(whatever_object, ["Hierarchy-Account-#{provider.id} Hierarchy-Account-43"], 'destroy')
  end

  test "compatibility object" do
    DeleteObjectHierarchyWorker.expects(:delete_later).with(provider)

    DeleteAccountHierarchyWorker.perform_now(provider)
  end
end
