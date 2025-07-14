require 'test_helper'

class AlertMessengerTest < ActiveSupport::TestCase

  def setup
    @provider_account = FactoryBot.create(:provider_account, :org_name => 'Foos & Bars', :domain => 'foosandbars.com', :self_domain => 'foosandbars-admin.com')
    @plan = FactoryBot.create( :application_plan, :issuer => @provider_account.first_service!)
    @buyer_account = FactoryBot.create(:buyer_account, :org_name => 'Buyer', :provider_account => @provider_account)
    @cinstance = FactoryBot.create(:cinstance, :plan => @plan, :name => "Foo Bar", :description => "Foo Bar Foo", :user_account => @buyer_account)
    @buyer_alert = FactoryBot.create(:limit_alert, :account => @buyer_account, :cinstance => @cinstance, :level => 50)
    @provider_violation = FactoryBot.create(:limit_violation, :account => @provider_account, :cinstance => @cinstance, :level => 150)
    @provider_violation_of_master = FactoryBot.create(:limit_violation, :account => @provider_account, :cinstance => @provider_account.bought_cinstances.first, :level => 150)
    Message.destroy_all
  end

  test 'send right email to buyer' do
    AlertMessenger.limit_message_for(@buyer_alert).deliver
    message = @buyer_account.received_messages.last

    assert_equal "Application 'Foo Bar' limit alert - limit usage is above 50%", message.subject
    assert_match "Dear Buyer", message.body
    assert_match %{Your application Foo Bar is above 50% limit utilization}, message.body
    assert_match "http://foosandbars.com/buyer/stats", message.body
    assert_equal @provider_account, message.sender
  end

end
