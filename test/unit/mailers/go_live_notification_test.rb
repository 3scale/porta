class GoLiveNotificationTest < ActionMailer::TestCase

  def setup
    ActionMailer::Base.deliveries = []
  end

  test "send the notification" do
    account = FactoryGirl.create(:provider_account)
    GoLiveNotification.notice(account).deliver_now
    email = ActionMailer::Base.deliveries.last
    assert_match account.domain, email.subject


    body = email.body.to_s
    assert_match(/#{account.domain}/, body)
    assert_match(/#{account.id}/, body)
    assert_match(/#{account.self_domain}/, body)
  end

end
