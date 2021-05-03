# frozen_string_literal: true

require 'test_helper'

class CreateDefaultProxyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'batch enqueue' do
    services = FactoryBot.create_list :service, 3
    no_proxy = services.last
    no_proxy.proxy.destroy!

    CreateDefaultProxyWorker::BatchEnqueueWorker.perform_now
    assert_enqueued_jobs 1, only: CreateDefaultProxyWorker
  end

  test 'perform create proxy' do
    service = FactoryBot.create :service
    service.proxy.destroy!
    service.expects(:create_default_proxy)

    CreateDefaultProxyWorker.perform_now service
  end
end
