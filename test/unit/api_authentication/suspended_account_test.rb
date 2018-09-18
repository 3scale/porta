class ApiAuthentication::SuspendedAccountTest < MiniTest::Unit::TestCase
  include ActiveSupport::Callbacks
  define_callbacks :action

  include AbstractController::Callbacks
  extend AbstractController::Callbacks::ClassMethods

  include ApiAuthentication::SuspendedAccount

  attr_reader :current_account

  def test_approved_account
    @current_account = stub('account', approved?: true)
    refute forbid_suspended_account_api_access
  end

  def test_suspended_account
    @current_account = stub('account', approved?: false)

    expects(:head).with(:forbidden).returns(true)
    assert forbid_suspended_account_api_access
  end

  def test_no_user
    refute forbid_suspended_account_api_access
  end
end
