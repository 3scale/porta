# frozen_string_literal: true

require 'test_helper'

class DeleteAccountHierarchyWorkerTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.schedule_for_deletion!
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

    buyers = FactoryBot.create_list(:buyer_account, 2, provider_account: provider)
    users = provider.users
    cms_sections = provider.sections

    DeleteObjectHierarchyWorker.stubs(:perform_later)
    users.each { |user| DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything, 'destroy') }
    services.each { |service| DeleteServiceHierarchyWorker.expects(:perform_later).with(service, anything, 'destroy') }
    buyers.each { |buyer| DeleteAccountHierarchyWorker.expects(:perform_later).with(buyer, anything, 'destroy').once }
    contracts.each do |contract|
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Contract.new({ id: contract.id }, without_protection: true), anything, 'destroy')
    end
    DeleteObjectHierarchyWorker.expects(:perform_later).with(account_plan, anything, 'destroy')
    cms_sections.each do |cms_section|
      DeleteObjectHierarchyWorker.expects(:perform_later).with(CMS::Section.new({ id: cms_section.id }, without_protection: true), anything, 'delete')
    end

    Sidekiq::Testing.inline! { DeleteAccountHierarchyWorker.perform_now(provider) }
  end

  test 'does not perform if wrong state' do
    provider.update_column(:state, 'approved')
    DeleteObjectHierarchyWorker.expects(:perform_later).never

    Sidekiq::Testing.inline! { DeleteAccountHierarchyWorker.perform_now(provider) }
  end

  test 'the account ends up destroyed after the hierarchy' do
    Sidekiq::Testing.inline! { DeleteAccountHierarchyWorker.perform_now(provider) }

    assert_raises(ActiveRecord::RecordNotFound) { provider.reload }
  end
end
