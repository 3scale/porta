require 'test_helper'

class DemoMessenger < Messenger::Base
    def welcome(account)
        @account = account
        assign_drops :account => @account

        message(
          :sender => account.provider_account,
          :subject => "Welcome to our service!",
          :to      => account
        )
    end

    def inline(account)
        @account = account
        assign_drops :account => @account

        message(
          :sender  => account.provider_account,
          :subject => "Body inline",
          :to      => account,
          :body    => "Hello {{account.name}} from inline template"
        )
    end

    def a_developer_portal_url
      developer_portal_routes.admin_account_invoice_url(1)
    end

    def a_app_url
      app_routes.provider_admin_account_invoice_url(1)
    end
end

class BaseTest < ActiveSupport::TestCase
  def setup
    CMS::EmailTemplate.templates_path = Rails.root.join('test/fixtures')
    #Liquidizer.template_paths << path unless Liquidizer.template_paths.include?(path)

    obs = MessageObserver.instance
    obs.stubs(:after_commit_on_create)

    @provider_account = Factory(:provider_account, :org_name => 'Foos & Bars',
                                :domain => 'foosandbars.com')

    @buyer_account = Factory(:buyer_account, :provider_account => @provider_account)

    Message.destroy_all
  end

  def teardown
    CMS::EmailTemplate.reset_templates_path!
  end

  def expected_message
    @provider_account.messages.first
  end


  test "app_url should take the global default_url_options" do
    Rails.configuration.action_mailer.stubs(default_url_options: {protocol: "lala", host: "foo"})
    demo = DemoMessenger.new
    assert_match(/lala/, demo.a_app_url)
    assert_match(/lala/, demo.a_developer_portal_url)
  end

  test "message sender is set" do
    DemoMessenger.welcome(@buyer_account)
    assert_equal @provider_account, expected_message.sender
  end

  test "message recipient is set" do
    DemoMessenger.welcome(@buyer_account)

    assert_equal [@buyer_account], expected_message.to
  end

  test "message subject is set" do
    DemoMessenger.welcome(@buyer_account)
    assert_equal "Welcome to our service!", expected_message.subject
  end

  test "message should be undelivered" do
    DemoMessenger.welcome(@buyer_account)
    assert_equal "unsent", expected_message.state
  end

  test "message should be sent when deliver is called" do
    DemoMessenger.welcome(@buyer_account).deliver
    assert_equal "sent", expected_message.state
  end

  test "message body is set" do
    DemoMessenger.welcome(@buyer_account)
    assert_equal "Hello #{@buyer_account.org_name}", expected_message.body
  end

  test "message inline template" do
    DemoMessenger.inline(@buyer_account)
    assert_equal "Hello #{@buyer_account.org_name} from inline template", expected_message.body
  end

  test "message template name is inferred" do
    expected = DemoMessenger.welcome(@buyer_account)
    assert_equal "demo_messenger_welcome", expected.full_template_name
  end

  test 'template_source' do
    master = Account.master
    messenger = DemoMessenger.new

    messenger.message(sender: @provider_account, to: master)
    assert_equal master, messenger.template_source

    messenger.message(sender: master, to: @provider_account)
    assert_equal master, messenger.template_source

    messenger.message(sender: @provider_account, to: @buyer_account)
    assert_equal @provider_account, messenger.template_source

    messenger.message(sender: @buyer_account, to: @provider_account)
    assert_equal @provider_account, messenger.template_source
  end

end
