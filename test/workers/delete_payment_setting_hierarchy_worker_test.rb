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

  test 'it performs for the buyers is it is destroyed by the provider association' do
    perform_enqueued_jobs do
      DeletePaymentSettingHierarchyWorker.perform_now(payment_gateway_setting,
        ["Hierarchy-Account-#{payment_gateway_setting.tenant_id}"])
    end

    buyers.each { |buyer| assert_raises(ActiveRecord::RecordNotFound) { buyer.reload } }
  end

  test 'it does not perform for the buyers if it is not destroyed by the provider association' do
    perform_enqueued_jobs { DeletePaymentSettingHierarchyWorker.perform_now(payment_gateway_setting, []) }

    buyers.each { |buyer| assert buyer.reload }
  end
end
