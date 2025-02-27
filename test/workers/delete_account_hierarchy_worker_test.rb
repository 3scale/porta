# frozen_string_literal: true

require 'test_helper'

class DeleteAccountHierarchyWorkerTest < ActiveSupport::TestCase
  attr_reader :provider

  setup do
    @provider = FactoryBot.create(:simple_provider)
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
