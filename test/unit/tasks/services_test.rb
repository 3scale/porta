# frozen_string_literal: true

require 'test_helper'

class Tasks::ServicesTest < ActiveSupport::TestCase
  test 'destroy_marked_as_deleted' do
    provider = FactoryGirl.create(:simple_provider)
    services = FactoryGirl.create_list(:simple_service, 2, account: provider)
    services.first.mark_as_deleted!

    DeleteObjectHierarchyWorker.expects(:perform_later).once.with do |object, _hierarchy|
      object.id == services.first.id
    end

    execute_rake_task 'services.rake', 'services:destroy_marked_as_deleted'
  end
end
