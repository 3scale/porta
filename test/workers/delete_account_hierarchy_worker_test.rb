# frozen_string_literal: true

require 'test_helper'

class DeleteAccountHierarchyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:provider_account, provider_account: master_account)
    provider.schedule_for_deletion!
  end

  attr_reader :provider

  test 'perform destroys the associations in background' do
    DeleteObjectHierarchyWorker.stubs(:perform_later)

    non_default_service = FactoryBot.create(:service, account: provider)
    non_default_service.stubs(:default?).returns(false)
    services = [provider.services.default, non_default_service]
    account_plan = provider.account_plans.default

    FactoryBot.create(:service_contract, user_account: provider)
    FactoryBot.create(:account_contract, user_account: provider)
    FactoryBot.create(:application_contract, user_account: provider)
    contracts = provider.reload.contracts

    users = provider.users
    cms_sections = provider.sections

    api_docs_service = FactoryBot.create(:api_docs_service, account: provider)

    DeleteObjectHierarchyWorker.stubs(:perform_later)
    users.each { |user| DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything, 'destroy') }
    services.each { |service| DeleteObjectHierarchyWorker.expects(:perform_later).with(service, anything, 'destroy') }
    contracts.each do |contract|
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Contract.new({ id: contract.id }, without_protection: true), anything, 'destroy')
    end
    DeleteObjectHierarchyWorker.expects(:perform_later).with(account_plan, anything, 'destroy')
    cms_sections.each do |cms_section|
      DeleteObjectHierarchyWorker.expects(:perform_later).with(CMS::Section.new({ id: cms_section.id }, without_protection: true), anything, 'delete')
    end
    DeletePaymentSettingHierarchyWorker.expects(:perform_later).with(provider.payment_gateway_setting, anything, 'destroy')
    DeleteObjectHierarchyWorker.expects(:perform_later).with(api_docs_service, anything, 'destroy')

    perform_enqueued_jobs { DeleteAccountHierarchyWorker.perform_now(provider) }
  end

  test 'does not perform if wrong state' do
    provider.update_column(:state, 'approved')

    perform_enqueued_jobs { DeleteAccountHierarchyWorker.perform_now(provider) }

    assert provider.reload
  end

  test 'the account ends up destroyed after the hierarchy' do
    perform_enqueued_jobs { DeleteAccountHierarchyWorker.perform_now(provider) }

    assert_raises(ActiveRecord::RecordNotFound) { provider.reload }
  end

  class DeleteBuyersTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    disable_transactional_fixtures!

    def setup
      @provider = FactoryBot.create(:provider_account, provider_account: master_account)
      provider.schedule_for_deletion!
      @buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: provider)
    end

    attr_reader :provider, :buyers

    test 'buyers are not destroyed through the tenant if the hierarchy comes from the tenant' do
      expect_buyers_perform_later(requested_times: :never)

      tenant_hierarchy_worker.perform(provider)
    end

    test 'buyers are destroyed through the tenant if it does not have a payment gateway setting' do
      provider.payment_gateway_setting.delete

      expect_buyers_perform_later(requested_times: :once)

      tenant_hierarchy_worker.perform(provider)
    end

    test 'buyers are destroyed through regular hierarchy if it is not called from the tenant' do
      buyers.each { |buyer| buyer.payment_detail.save! && DeleteObjectHierarchyWorker.expects(:perform_later).with(buyer.payment_detail, anything, 'destroy') }

      buyers.each { |buyer| perform_enqueued_jobs { DeleteAccountHierarchyWorker.perform_now(buyer) } }

      buyers.each { |buyer| assert_raises(ActiveRecord::RecordNotFound) { buyer.reload } }
    end

    private

    def tenant_hierarchy_worker
      @tenant_hierarchy_worker ||= begin
        worker = DeleteAccountHierarchyWorker.new
        worker.instance_variable_set(:@caller_worker_hierarchy, ["Hierarchy-Account-#{provider.id}"])
        worker.instance_variable_set(:@object, provider)
        worker
      end
    end

    def expect_buyers_perform_later(requested_times:)
      buyers.each do |buyer|
        DeleteAccountHierarchyWorker.expects(:perform_later)
          .with(buyer, ["Hierarchy-Account-#{provider.id}"], 'destroy')
          .public_send(requested_times)
      end
    end

  end
end
