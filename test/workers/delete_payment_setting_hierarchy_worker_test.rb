# frozen_string_literal: true

require 'test_helper'

class DeletePaymentSettingHierarchyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    tenant = FactoryBot.create(:simple_provider)
    tenant.schedule_for_deletion!
    @payment_gateway_setting = FactoryBot.create(:payment_gateway_setting, account: tenant, tenant_id: tenant.id)
    @buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: tenant)
  end

  attr_reader :payment_gateway_setting, :buyers

  test 'it performs' do
    perform_enqueued_jobs do
      DeletePaymentSettingHierarchyWorker.delete_later(payment_gateway_setting)
    end

    assert_raises(ActiveRecord::RecordNotFound) { payment_gateway_setting.reload }
    buyers.each(&:reload)
  end
end
