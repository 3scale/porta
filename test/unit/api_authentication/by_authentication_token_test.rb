require 'test_helper'

class ApiAuthentication::ByAuthenticationTokenTest < MiniTest::Unit::TestCase
  include ActiveSupport::Callbacks
  define_callbacks :action
  include ActiveSupport::Rescuable

  include AbstractController::Callbacks
  extend AbstractController::Callbacks::ClassMethods


  include ApiAuthentication::ByAccessToken

  attr_reader :domain_account, :params

  def setup
    @domain_account = stub('account', access_tokens: @access_tokens = mock('access_tokens'))
  end

  def mock_token(attributes = {})
    @params = { access_token: 'some-token' }
    token = mock('access-token', attributes)
    @access_tokens.expects(:by_value).with('some-token').returns(token)
    token
  end

  def test_current_user
    _token = mock_token(owner: @user = mock('user'))
    assert_equal @user, current_user
  end

  def test_authenticated_token_correct_scope
    owner  = mock('user', allowed_access_token_scopes: { 'Alaska' => 'cms' })
    _token = mock_token(scopes: ['cms'], owner: owner)

    self.class.access_token_scopes = [:cms]

    assert verify_access_token_scopes
  end

  def test_rescue_handlers
    handlers = {
        'ApiAuthentication::ByAccessToken::Error' => :show_access_key_permission_error
    }
    assert_equal handlers, rescue_handlers.to_h
  end

  def test_authenticated_token_invalid_scope
    owner  = mock('user', allowed_access_token_scopes: { 'Alaska' => 'finance' })
    _token = mock_token(scopes: ['some-other-scope'], owner: owner)

    self.class.access_token_scopes = [:finance]

    assert_raises(ScopeError) { verify_access_token_scopes }
  end

  def test_authenticated_token_forbidden_user_access_token_scope
    owner  = mock('user', allowed_access_token_scopes: { 'Alaska' => 'finance' })
    _token = mock_token(owner: owner)

    self.class.access_token_scopes = [:cms]

    assert_raises(PermissionError) { verify_access_token_scopes }
  end

  def test_enforce_access_token_ro_permission
    _token = mock_token(permission: 'ro')

    assert_raises PermissionError do
      enforce_access_token_permission do
        User.delete_all
      end
    end
  end

  def test_enforce_access_token_rw_permission
    _token = mock_token(permission: 'rw')

    enforce_access_token_permission do
      User.delete_all
    end
  end

end
