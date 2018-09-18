require 'test_helper'

class CinstanceMessengerTest < ActiveSupport::TestCase

  def setup
    @provider_account = Factory(:provider_account, :org_name => 'Foos & Bars', :domain => 'foosandbars.com')
    @plan = Factory( :application_plan, :issuer => @provider_account.first_service!)
    @app = Factory(:cinstance, :plan => @plan, :name => "Foo Bar", :description => "Foo Bar Foo")

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

  test "contract cancelation" do
    CinstanceMessenger.contract_cancellation(@app).deliver
    message = @app.provider_account.received_messages.last

    expected_match = "We have deleted the application #{@app.name} on application plan #{@app.plan.name} of your service #{@app.provider_account.first_service!.name} in the developer account #{@app.user_account.name}."
    assert_match expected_match, message.body
  end

  test "new application with multiple applications" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'visible')

    CinstanceMessenger.new_application(@app).deliver

    assert_match "#{@app.user_account.org_name} has submitted a new application for your API.", Message.last.body
    assert_match "Application title: #{@app.name}", Message.last.body
    assert_match "Application description:\n\n#{@app.description}", Message.last.body
    assert_match "New Application submission", Message.last.subject
  end

  test "new application with multiple applications and approval required" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'visible')
    @plan.update_attribute  :approval_required, true

    CinstanceMessenger.new_application(@app).deliver

    assert_match "This application requires your approval", Message.last.body
    assert_match "http://#{@provider_account.admin_domain}/buyers/applications/#{@app.id}", Message.last.body
  end

  test "new application without multiple applications and approval required" do
    @app.provider_account.settings.update_attribute(:multiple_applications_switch, 'hidden')
    @plan.update_attribute  :approval_required, true

    CinstanceMessenger.new_application(@app).deliver

    assert_match "#{@app.user_account.admins.first.username} has signed up for your service #{@app.service.name} on plan #{@app.plan.name}.",
      Message.last.body
    assert_match "service requires you to approve", Message.last.body
    assert_match "New Application submission", Message.last.subject
  end

  test "new application without multiple applications displays user information" do
    @app.provider_account.stubs(:multiple_applications_allowed?).returns(false)
    CinstanceMessenger.new_application(@app).deliver
    message = Message.last.body
    user = @app.user_account.admins.first
    user_account = @app.user_account
    assert_match "Name: #{user.full_name}", message
    assert_match "Email: #{user.email}", message
    assert_match "Organization: #{user_account.org_name}", message
    assert_match "Telephone: #{user_account.telephone_number}", message
  end

  test "plan change" do
    old_plan = Factory( :application_plan, :issuer => @provider_account.first_service!)
    @app.stubs(old_plan: old_plan)
    CinstanceMessenger.plan_change(@app).deliver
    message = @app.provider_account.received_messages.last
    expected = "#{@app.user_account.org_name} of your service #{@app.service.name} has changed his/her plan from #{old_plan.name} to #{@app.plan.name}."
    assert_match expected, message.body
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


  class ProviderAndMasterTest < ActiveSupport::TestCase

    def setup
      SystemOperation.for('plan_change')
    end

    def test_plan_change_for_buyer
      provider = FactoryGirl.create(:provider_account)

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

    def test_plan_change
      provider = FactoryGirl.create(:provider_account)

      app = provider.bought_cinstance

      provider_template = provider.email_templates.new_by_system_name('cinstance_messenger_plan_change')
      provider_template.published = 'foobar'
      provider_template.save!

      master = Account.master
      master_template = master.email_templates.new_by_system_name('cinstance_messenger_plan_change')
      master_template.published = 'master template'
      master_template.save!
      master.received_messages.destroy_all
      master.reload

      messenger = CinstanceMessenger.plan_change(app)

      assert messenger.deliver
      assert provider.received_messages.empty?

      message = master.received_messages.last!
      assert_match 'master template', message.body
    end

  end
end
