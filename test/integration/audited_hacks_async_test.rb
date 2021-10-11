# frozen_string_literal: true

require 'test_helper'

class AuditedHacksAsyncTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  include TestHelpers::Sidekiq

  attr_reader :provider, :admin, :audit_class

  setup do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    @provider = FactoryBot.create(:simple_provider)
    @admin = FactoryBot.create :simple_user, account: @provider, role: 'admin'
    User.current = @admin

    host! provider.admin_domain

    @audit_class = Audited.audit_class

    audit_class.delete_all
  end

  test "async auditing sets all attributes" do
    with_sidekiq do
      User.with_auditing do
        put(admin_api_user_path(format: :xml, id: admin.id), params: { email: "async-audit@example.com", access_token: account_management_admin_token.value })
        assert_response :ok
      end
    end

    assert_equal 1, Audited.audit_class.count
    assert_equal 1, last_audit.version
    assert_equal User.current, last_audit.user
    assert_not_empty last_audit.request_uuid
    assert_not_empty last_audit.remote_address
  end

  test "no audit during API call in async mode" do
    # make sure last version is never queried during API call
    Audited::Audit.expects(:auditable_finder).never
    Audited::Audit.any_instance.expects(:set_version_number).never

    User.with_auditing do
      put(admin_api_user_path(format: :xml, id: admin.id), params: {email: "async-audit@example.com", access_token: account_management_admin_token.value})
      assert_response :ok
    end

    # before Sidekiq job processing, no audit was created
    assert_equal 0, Audited.audit_class.count
  end

  test "async audit version selected on actual creation" do
    User.with_auditing do
      put(admin_api_user_path(format: :xml, id: admin.id), params: {email: "async-audit@example.com", access_token: account_management_admin_token.value})
      assert_response :ok
    end

    User.with_synchronous_auditing do
      put(admin_api_user_path(format: :xml, id: admin.id), params: {email: "sync-audit@example.com", access_token: account_management_admin_token.value})
      assert_response :ok
    end

    drain_all_sidekiq_jobs

    assert_equal 2, Audited.audit_class.count
    assert_equal 2, last_audit.version
    assert_equal "async-audit@example.com", last_audit.new_attributes["email"]
  end

  test "async audit version is set only once" do
    Audited::Audit.any_instance.expects(:set_version_number).once

    with_sidekiq do
      User.with_auditing do
        put(admin_api_user_path(format: :xml, id: admin.id), params: { email: "async-audit@example.com", access_token: account_management_admin_token.value })
        assert_response :ok
      end
    end
  end

  test "async audit request UUID is from actual API call" do
    expected_uuid = SecureRandom.uuid
    ActionDispatch::Request.any_instance.expects(:uuid).returns(expected_uuid).at_least_once

    User.with_auditing do
      put(admin_api_user_path(format: :xml, id: admin.id), params: {email: "async-audit@example.com", access_token: account_management_admin_token.value})
      assert_response :ok
    end

    expected_another_uuid = SecureRandom.uuid
    ActionDispatch::Request.any_instance.stubs(:uuid).returns(expected_another_uuid)

    User.with_auditing do
      put(admin_api_user_path(format: :xml, id: admin.id), params: {email: "second-audit@example.com", access_token: account_management_admin_token.value})
      assert_response :ok
    end

    drain_all_sidekiq_jobs

    assert_equal expected_uuid, first_audit.request_uuid
    assert_equal expected_another_uuid, last_audit.request_uuid
  end

  test "async audit user is set from actual API call" do
    User.with_auditing do
      put(admin_api_user_path(format: :xml, id: admin.id), params: { email: "async-audit@example.com", access_token: account_management_admin_token.value })
      assert_response :ok
    end

    User.current = nil

    drain_all_sidekiq_jobs

    assert_not_nil last_audit.user
  end

  private

  def account_management_admin_token
    FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])
  end

  def first_audit
    Audited.audit_class.first!
  end

  def last_audit
    Audited.audit_class.last!
  end
end
