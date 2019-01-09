# frozen_string_literal: true

require 'test_helper'

class Tasks::ServicesTest < ActiveSupport::TestCase
  test 'destroy_marked_as_deleted' do
    DestroyAllDeletedObjectsWorker.expects(:perform_async).once.with('Service')

    execute_rake_task 'services.rake', 'services:destroy_marked_as_deleted'
  end
end
