require 'test_helper'

class CinstanceMessengerTest < ActiveSupport::TestCase

  def setup
    @provider_account = FactoryBot.create(:provider_account, :org_name => 'Foos & Bars', :domain => 'foosandbars.com')
    @plan = FactoryBot.create( :application_plan, :issuer => @provider_account.first_service!)
    @app = FactoryBot.create(:cinstance, :plan => @plan, :name => "Foo Bar", :description => "Foo Bar Foo")

    Message.destroy_all
  end

  test 'expired_trial_period_notification' do
    CinstanceMessenger.expired_trial_period_notification(@app).deliver
    message = @app.user_account.received_messages.last

    assert_equal "Foos & Bars API - Trial period expiry", message.subject
    assert_match "Dear #{@app.user_account.org_name}", message.body
    # assert_match "http://foosandbars.com/plans", message.body # we dont have it now
  end

   test 'expired_trial_period_notification with support_email' do
    support_email = "test@example.com"
    @app.service.stubs(:support_email).returns(support_email)

    assert_equal support_email, @app.service.support_email

    CinstanceMessenger.expired_trial_period_notification(@app).deliver

    message = @app.user_account.received_messages.last
    expected_match = "If you have any questions, feel free to contact our support team at #{support_email}."
    assert_match expected_match, message.body
   end

  test "application accept with multiple_applications_allowed" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'visible')

    CinstanceMessenger.accept(@app).deliver

    message = @app.user_account.received_messages.last
    expected = "#{@app.provider_account.org_name} has approved your application #{@app.name}"
    assert_match expected, message.body
  end

  test "application accept without multiple_applications_allowed" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'hidden')

    CinstanceMessenger.accept(@app).deliver

    message = @app.user_account.received_messages.last
    expected =   "#{@app.provider_account.org_name} has approved your signup for service #{@app.service.name} (#{@app.plan.name})"
    assert_match expected, message.body
  end

  test "application reject with multiple_applications_allowed" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'visible')

    CinstanceMessenger.reject(@app).deliver

    message = @app.user_account.received_messages.last
    expected = "#{@app.provider_account.org_name} has rejected your application"
    assert_match expected, message.body
  end

  test "application reject without multiple_applications_allowed" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'hidden')

    CinstanceMessenger.reject(@app).deliver

    message = @app.user_account.received_messages.last
    expected =   "#{@app.provider_account.org_name} has rejected your application for service #{@app.service.name} (#{@app.plan.name})"
    assert_match expected, message.body
  end

  # settings should not be missing at this point but could in edge cases during deletion
  test "application reject without a settings object" do
    @provider_account.schedule_for_deletion!
    @provider_account.settings.delete
    assert_nil @provider_account.reload.settings

    CinstanceMessenger.reject(@app).deliver

    message = @app.user_account.received_messages.last
    expected =   "#{@app.provider_account.org_name} has rejected your application for service #{@app.service.name} (#{@app.plan.name})"
    assert_match expected, message.body
  end

  class ProviderAndMasterTest < ActiveSupport::TestCase

    def setup
      SystemOperation.for('plan_change')
    end

    def test_plan_change_for_buyer
      provider = FactoryBot.create(:provider_account)

      app = provider.bought_cinstance

      provider_template = provider.email_templates.new_by_system_name('cinstance_messenger_plan_change_for_buyer')
      provider_template.published = 'foobar'
      provider_template.save!

      master_template = Account.master.email_templates.new_by_system_name('cinstance_messenger_plan_change_for_buyer')
      master_template.published = 'master template'
      master_template.save!

      CinstanceMessenger.plan_change_for_buyer(app).deliver

      message = provider.received_messages.last!
      expected =   "master template"
      assert_match expected, message.body
    end

  end
end
