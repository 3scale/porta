# frozen_string_literal: true

require 'test_helper'

class SetTenantIdWorkerTest < ActiveSupport::TestCase

  class BatchEnqueueWorkerTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "perform with a single relation" do
      accounts = FactoryBot.create_list(:provider_account, 2, :with_a_buyer)
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

    test "account relations are also fixed for buyer accounts" do
      buyer = FactoryBot.create(:buyer_account)
      provider = buyer.provider_account

      assert_equal provider.id, buyer.reload.tenant_id

      alert_provider = FactoryBot.create(:limit_alert, account: provider)
      alert_buyer = FactoryBot.create(:limit_alert, account: buyer)

      [alert_provider, alert_buyer].each do |alert|
        assert_equal provider.id, alert.reload.tenant_id
        alert.tenant_id = nil
        assert_nil alert.tenant_id
      end

      perform_enqueued_jobs(only: [SetTenantIdWorker, SetTenantIdWorker::ModelTenantIdWorker]) do
        SetTenantIdWorker::BatchEnqueueWorker.new.perform("backend_apis", "alerts")
      end

      assert_equal provider.id, alert_provider.reload.tenant_id
      assert_equal provider.id, alert_buyer.reload.tenant_id
    end

    test "raises on empty params" do
      assert_raises do
        SetTenantIdWorker::BatchEnqueueWorker.new.perform
      end
    end

    test "raises on unsupported relations" do
      assert_raises do
        # unsupported relation that
        SetTenantIdWorker::BatchEnqueueWorker.new.perform("accounts")
      end
    end

    test "raises on non-existing relations" do
      assert_raises do
        SetTenantIdWorker::BatchEnqueueWorker.new.perform("non-existing-relation", "alerts")
      end
    end
  end
end
