require 'test_helper'

# provider side
class Provider::Admin::Account::NotificationsControllerTest < ActionController::TestCase

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
  end

  test 'success update should redirect to list notifications' do
    rule = @provider.mail_dispatch_rules.create!(system_operation: SystemOperation.for(:user_signup))
    put :update, id: rule.id, mail_dispatch_rule: { dispatch: true }
    assert_redirected_to provider_admin_account_notifications_path
  end
end
