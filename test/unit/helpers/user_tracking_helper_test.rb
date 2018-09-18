require 'test_helper'

class UserTrackingHelperTest < ActionView::TestCase

  include ThreeScale::Analytics::SessionStoredAnalytics::Helper

  attr_accessor :current_user

  test '#analytics_identity_data' do
    self.current_user = FactoryGirl.build_stubbed(:user_with_account)

    assert analytics_identity_data
  end
end
