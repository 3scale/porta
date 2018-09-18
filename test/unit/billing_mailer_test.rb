class BillingMailerTest < ActionMailer::TestCase

  def setup
    ActionMailer::Base.deliveries = []
  end

  test "success" do
    results = Finance::BillingStrategy::Results.new(Time.now)

    BillingMailer.billing_finished(results).deliver_now

    email = ActionMailer::Base.deliveries.last
    assert_match "Billing and charging succeeded", email.subject
    assert_equal [ThreeScale.config.sysadmin_email], email.to
  end

  test "failure" do
    results = Finance::BillingStrategy::Results.new(Time.now)
    results.stubs(:successful?).returns(false)

    BillingMailer.billing_finished(results).deliver_now

    email = ActionMailer::Base.deliveries.last
    assert_match "Billing and charging failed", email.subject
    assert_equal [ThreeScale.config.sysadmin_email], email.to
  end
end
