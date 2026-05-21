# frozen_string_literal: true

require 'test_helper'

class ApiAuthentication::ByZyncTokenTest < ActiveSupport::TestCase
  # Minimal host object that includes ByZyncToken so we can call its methods directly.
  class Host
    include ActiveSupport::Callbacks
    define_callbacks :action
    include ActiveSupport::Rescuable
    include AbstractController::Callbacks
    extend AbstractController::Callbacks::ClassMethods

    include ApiAuthentication::ByAccessToken
    include ApiAuthentication::ByZyncToken

    attr_reader :request, :domain_account, :params

    def initialize(request:, domain_account:)
      @request = request
      @domain_account = domain_account
      @params = {}
    end
  end

  def setup
    @user    = stub('user')
    @account = stub('account', master?: false,
                               find_impersonation_admin: nil,
                               first_admin!: @user)
    @request = stub('request', authorization: nil)
    @host    = Host.new(request: @request, domain_account: @account)
  end

  # authenticate_zync_request

  test '#authenticate_zync_request sets zync_authenticated flag for a valid Zync request' do
    AuthenticatedSystem::Request.stubs(:new).with(@request).returns(stub(zync?: true))

    @host.send(:authenticate_zync_request)

    assert @host.instance_variable_get(:@zync_authenticated)
  end

  test '#authenticate_zync_request is a no-op when X-Zync-Token is wrong' do
    AuthenticatedSystem::Request.stubs(:new).with(@request).returns(stub(zync?: false))

    @host.send(:authenticate_zync_request)

    assert_nil @host.instance_variable_get(:@zync_authenticated)
  end

  test '#authenticate_zync_request is a no-op when domain is master' do
    AuthenticatedSystem::Request.stubs(:new).with(@request).returns(stub(zync?: true))
    @account.stubs(:master?).returns(true)

    @host.send(:authenticate_zync_request)

    assert_nil @host.instance_variable_get(:@zync_authenticated)
  end

  # current_user

  test '#current_user falls back to first_admin! when no impersonation admin exists' do
    AuthenticatedSystem::Request.stubs(:new).with(@request).returns(stub(zync?: true))
    @host.send(:authenticate_zync_request)

    assert_equal @user, @host.send(:current_user)
  end

  test '#current_user prefers the impersonation admin over first_admin!' do
    impersonation_admin = stub('impersonation_admin')
    @account.stubs(:find_impersonation_admin).returns(impersonation_admin)
    AuthenticatedSystem::Request.stubs(:new).with(@request).returns(stub(zync?: true))
    @host.send(:authenticate_zync_request)

    assert_equal impersonation_admin, @host.send(:current_user)
  end

  test '#current_user delegates to super for non-Zync requests' do
    AuthenticatedSystem::Request.stubs(:new).with(@request).returns(stub(zync?: false))
    @host.send(:authenticate_zync_request)

    assert_nil @host.send(:current_user)
  end

  # enforce_access_token_permission

  class EnforcePermissionTest < ApiAuthentication::ByZyncTokenTest
    # Read-only transaction enforcement can't run inside a transaction.
    self.use_transactional_tests = false

    test '#enforce_access_token_permission enforces a read-only DB transaction for Zync requests' do
      @host.instance_variable_set(:@zync_authenticated, true)

      assert_raises ApiAuthentication::ByAccessToken::PermissionError do
        @host.send(:enforce_access_token_permission) { User.delete_all }
      end
    end
  end

  test '#enforce_access_token_permission delegates to ByAccessToken for non-Zync requests' do
    # @zync_authenticated is not set — falls through to ByAccessToken's version.
    # With no authenticated_token (no access_token param, no HTTP auth) it yields normally.
    executed = false
    @host.send(:enforce_access_token_permission) { executed = true }
    assert executed
  end
end
