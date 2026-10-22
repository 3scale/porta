# frozen_string_literal: true

require 'test_helper'

class ApiAuthentication::SuspendedAccountTest < SimpleMiniTest
  include ActiveSupport::Callbacks

  define_callbacks :action

  include AbstractController::Callbacks
  extend AbstractController::Callbacks::ClassMethods

  include ApiAuthentication::SuspendedAccount

  attr_reader :current_account

  def test_approved_account
    @current_account = stub('account', approved?: true)
    assert_not forbid_suspended_account_api_access
  end

  def test_unapproved_provider_without_zync_authentication
    @current_account = stub('provider', approved?: false, provider?: true)
    stubs(:authenticated_request).returns(stub(zync?: false))

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_unapproved_provider_with_zync_authentication
    @current_account = stub('provider', approved?: false, provider?: true, scheduled_for_deletion?: false)
    stubs(:authenticated_request).returns(stub(zync?: true))

    expects(:head).never
    assert_nil forbid_suspended_account_api_access
  end

  def test_scheduled_provider_with_zync_authentication
    @current_account = stub('provider', approved?: false, provider?: true, scheduled_for_deletion?: true)
    stubs(:authenticated_request).returns(stub(zync?: true))

    expects(:head).with(:not_found).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_unapproved_buyer_with_zync_authentication
    @current_account = stub('buyer', approved?: false, provider?: false)
    stubs(:authenticated_request).returns(stub(zync?: true))

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_no_user
    assert_not forbid_suspended_account_api_access
  end
end
