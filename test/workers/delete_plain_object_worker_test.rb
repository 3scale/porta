# frozen_string_literal: true

require 'test_helper'

class DeletePlainObjectWorkerTest < ActiveSupport::TestCase
  test "compatibility" do
    provider = FactoryBot.create(:simple_provider)
    whatever_object = provider.default_service
    DeleteObjectHierarchyWorker.expects(:delete_later).with(provider)

    DeletePlainObjectWorker.perform_now(whatever_object, ["Hierarchy-Account-#{provider.id} Hierarchy-Account-43"], 'destroy')
  end
end
