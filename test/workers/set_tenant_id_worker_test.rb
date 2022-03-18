# frozen_string_literal: true

require 'test_helper'

class SetTenantIdWorkerTest < ActiveSupport::TestCase

  class BatchEnqueueWorkerTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "perform with a single relation" do
      accounts = FactoryBot.create_list(:simple_provider, 2)
      backend_api = FactoryBot.create(:backend_api, account: accounts.first)
      backend_api2 = FactoryBot.create(:backend_api, account: accounts.last)
      alert = FactoryBot.create(:limit_alert, account: accounts.first)
      assert_equal accounts.first.id, backend_api.reload.tenant_id

      backend_api.tenant_id = nil
      backend_api.save!
      assert_nil backend_api.reload.tenant_id

      alert.reload.tenant_id = nil
      alert.save!
      assert_nil alert.reload.tenant_id

      perform_enqueued_jobs(only: [SetTenantIdWorker, SetTenantIdWorker::ModelTenantIdWorker]) do
        SetTenantIdWorker::BatchEnqueueWorker.new.perform("backend_apis")
      end

      assert_equal accounts.first.id, backend_api.reload.tenant_id
      assert_equal accounts.last.id, backend_api2.reload.tenant_id
      assert_nil alert.reload.tenant_id
    end
  end
end
