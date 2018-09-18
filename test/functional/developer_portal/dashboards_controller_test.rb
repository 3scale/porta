require 'test_helper'

class DeveloperPortal::DashboardsControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    super
    @provider = Factory(:provider_account)
    @buyer = Factory(:buyer_account, provider_account: @provider)
    login_buyer(@buyer)
  end

  test 'trial' do
    @plan = Factory(:application_plan, service: @provider.first_service!, trial_period_days: 10)
    @app = Factory(:cinstance, plan: @plan, user_account: @buyer)

    get :show

    assert_response :success
    assert_select 'h3', text: 'Trial period'
    assert_select 'p', text: '10 days remaining.'
  end

  # Remove when all such templates are gone. It's using trial_notice,
  # latest_messages and lates_forum_posts tags.
  test 'legacy liquid template' do
    legacy_code = "<h2>Dashboard</h2>\n{% trial_notice %}\n\n{% if account.credit_card_required? and account.credit_card_missing? %}\n  <div class=\"dashboard_bubble round\">\n    {% credit_card_missing %}\n  </div>\n{% endif %}\n\n<div class=\"dashboard_bubble round\">\n  <h3>Messages</h3>\n  {% latest_messages %}\n</div>\n\n{% latest_forum_posts %}\n"

    SimpleLayout.new(@provider).create_builtin_pages_and_partials!
    dashboard = @provider.builtin_pages.find_or_create!('dashboards/show', 'Dashboard', @provider.sections.root)
    dashboard.update_attribute(:published, legacy_code)

    get :show

    assert_response :success
  end

end
