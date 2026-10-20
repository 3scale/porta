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

  def test_suspended_account
    @current_account = stub('account', approved?: false, provider?: true, scheduled_for_deletion?: false)

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_scheduled_provider_with_oidc_synchronization_token
    scheduled_provider
    stubs(:request).returns(stub(get?: true))
    stubs(:authenticated_request).returns(stub(zync?: true))
    stubs(:authenticated_token).returns(stub(name: AccessToken::OIDC_SYNC_TOKEN))

    assert_not forbid_suspended_account_api_access
  end

  def test_scheduled_provider_rejects_ordinary_access_tokens
    scheduled_provider
    stubs(:request).returns(stub(get?: true))
    stubs(:authenticated_request).returns(stub(zync?: true))
    stubs(:authenticated_token).returns(stub(name: 'Personal access token'))

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_scheduled_provider_requires_get
    scheduled_provider
    stubs(:request).returns(stub(get?: false))

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_scheduled_provider_requires_zync_authentication
    scheduled_provider
    stubs(:request).returns(stub(get?: true))
    stubs(:authenticated_request).returns(stub(zync?: false))

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_scheduled_provider_requires_access_token
    scheduled_provider
    stubs(:request).returns(stub(get?: true))
    stubs(:authenticated_request).returns(stub(zync?: true))
    stubs(:authenticated_token).returns(nil)

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_scheduled_buyer
    @current_account = stub('buyer', approved?: false, provider?: false)

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_no_user
    assert_not forbid_suspended_account_api_access
  end

  private

  def scheduled_provider
    @current_account = stub('provider', approved?: false, provider?: true, scheduled_for_deletion?: true)
  end
end
