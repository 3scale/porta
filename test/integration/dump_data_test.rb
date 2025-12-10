# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

class DumpDataTest < ActiveSupport::TestCase
  include TestHelpers::Provider

  # Disable transactional tests because we need to shell out to rails runner
  # which needs to see committed data in the database
  self.use_transactional_tests = false

  DUMP_SCRIPT_PATH = Rails.root.join('script', 'dump_data.rb')

  test 'dump and restore maintains database integrity and sequences' do
    # Create a complete provider with all associations
    provider = create_a_complete_provider

    # Store some IDs to verify later
    provider_id = provider.id
    admin_user_id = provider.admin_user.id
    service_id = provider.default_service.id
    buyer_ids = provider.buyers.pluck(:id)
    invoice_ids = Invoice.where(provider_account: provider).pluck(:id)

    # Get a policy to verify serialized attributes are preserved
    policy = Policy.find_by(account: provider)
    original_policy_schema = policy.schema

    # Count all records before dump
    initial_counts = count_all_records

    # Dump the database to a temporary file
    dump_file = Tempfile.new(['dump_data', '.jsonl'])

    begin
      # Export data - Don't redirect stderr to stdout
      system("RAILS_LOG_TO_STDOUT=false bundle exec rails runner #{DUMP_SCRIPT_PATH} export > #{dump_file.path}")
      assert_equal 0, $?.exitstatus, "Export failed with status #{$?.exitstatus}"

      # Verify dump file is valid JSONL
      verify_jsonl_format(dump_file.path)

      # Truncate the database (except schema tables)
      truncate_output = `bundle exec rails runner #{DUMP_SCRIPT_PATH} truncate-all < #{dump_file.path} 2>&1`
      assert_equal 0, $?.exitstatus, "Truncate failed: #{truncate_output}"

      # Verify database is empty (most tables should be empty now)
      Account.connection.clear_query_cache
      assert_equal 0, Account.count, "Accounts should be deleted after truncate"
      assert_equal 0, Service.count, "Services should be deleted after truncate"
      assert_equal 0, User.count, "Users should be deleted after truncate"

      # Restore the database
      import_output = `bundle exec rails runner #{DUMP_SCRIPT_PATH} import --no-truncate < #{dump_file.path} 2>&1`
      assert_equal 0, $?.exitstatus, "Import failed: #{import_output}"

      # Clear query cache to ensure we're reading fresh data
      Account.connection.clear_query_cache

      # Verify all records were restored
      restored_counts = count_all_records

      # Compare counts - they should match
      initial_counts.each do |table, count|
        assert_equal count, restored_counts[table],
          "Table #{table} should have #{count} records after restore, but has #{restored_counts[table]}"
      end

      # Verify specific objects were restored correctly
      restored_provider = Account.find(provider_id)
      assert_not_nil restored_provider, "Provider should be restored"
      assert_equal provider.name, restored_provider.name

      restored_admin = User.find(admin_user_id)
      assert_not_nil restored_admin, "Admin user should be restored"
      assert_equal provider.admin_user.email, restored_admin.email

      restored_service = Service.find(service_id)
      assert_not_nil restored_service, "Service should be restored"
      assert_equal service_id, restored_service.id

      # Verify buyers were restored
      buyer_ids.each do |buyer_id|
        assert Account.exists?(buyer_id), "Buyer #{buyer_id} should exist after restore"
      end

      # Verify invoices were restored
      invoice_ids.each do |invoice_id|
        assert Invoice.exists?(invoice_id), "Invoice #{invoice_id} should exist after restore"
      end

      # Test that sequences are working correctly by creating new objects
      # This verifies that sequences were properly reset after import

      # Create a new account
      new_account = FactoryBot.build(:simple_account)
      assert new_account.save, "Should be able to create new account (sequence should work)"
      assert new_account.id > provider_id, "New account ID should be greater than restored provider ID"

      # Create a new user
      new_user = FactoryBot.build(:simple_user, account: restored_provider)
      assert new_user.save, "Should be able to create new user (sequence should work)"
      assert new_user.id > admin_user_id, "New user ID should be greater than restored admin ID"

      # Create a new service
      new_service = FactoryBot.build(:simple_service, account: restored_provider)
      assert new_service.save, "Should be able to create new service (sequence should work)"
      assert new_service.id > service_id, "New service ID should be greater than restored service ID"

      # Verify relationships are intact
      assert_equal restored_provider.id, restored_admin.account_id, "Admin user should belong to provider"
      assert_equal restored_provider.id, restored_service.account_id, "Service should belong to provider"
      assert_includes restored_provider.buyers.pluck(:id), buyer_ids.first, "Provider should have buyers"

      # Verify serialized attributes are preserved
      restored_policy = Policy.find(policy.id)
      assert_equal original_policy_schema, restored_policy.schema,
        "Serialized policy schema should be preserved after restore"
    ensure
      dump_file.close
      dump_file.unlink
    end
  end

  private

  def verify_jsonl_format(file_path)
    # Verify file is not empty
    assert File.size(file_path) > 0, "Dump file should not be empty"

    # Read and verify each line is valid JSON with correct structure
    line_count = 0
    jsonl_ahead = false
    File.foreach(file_path) do |line|
      line_count += 1
      next unless jsonl_ahead || line.start_with?('{') # some log lines sneak in initially unfortunately
      jsonl_ahead = true
      data = JSON.parse(line)
      assert data.key?('table'), "Line #{line_count} should have a 'table' key"
      assert data.key?('data'), "Line #{line_count} should have a 'data' key"
      assert data['data'].is_a?(Array), "Line #{line_count}: 'data' value should be an array"
    end

    assert line_count > 0, "Should have exported at least one line"
  end

  def count_all_records
    counts = {}

    # Count records in all important tables
    [
      Account, User, Service, Cinstance, Invoice, LineItem,
      ServicePlan, ApplicationPlan, AccountPlan,
      Metric, UsageLimit, PricingRule,
      AccessToken, ApiDocs::Service, WebHook,
      CMS::Template, CMS::Layout, CMS::Page, CMS::Section,
      Feature, FeaturesPlan,
      ProxyConfig, PaymentDetail, PaymentTransaction,
      Invitation,
      Policy,
      AuthenticationProvider
    ].each do |model|
      counts[model.table_name] = model.count
    end

    counts
  end
end