require 'test_helper'

class Provider::Admin::Account::EnforceSSOTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_create
    user = FactoryBot.create(:user, account: @provider)
    user_session = user.user_sessions.create

    EnforceSSOValidator.any_instance.expects(:valid?).returns(false)
    post provider_admin_account_enforce_sso_path
    refute @provider.reload.settings.enforce_sso
    assert user_session.reload

    EnforceSSOValidator.any_instance.expects(:valid?).returns(true)
    post provider_admin_account_enforce_sso_path
    assert @provider.reload.settings.enforce_sso
    assert_raise(ActiveRecord::RecordNotFound) { user_session.reload }
  end

  def test_destroy
    @provider.settings.update_attributes(enforce_sso: true)
    assert @provider.reload.settings.enforce_sso
    delete provider_admin_account_enforce_sso_path
    refute @provider.reload.settings.enforce_sso
  end
end
