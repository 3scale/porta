require 'test_helper'

class PostOfficeTest < ActionMailer::TestCase
  setup do
    ActionMailer::Base.deliveries = []
    @host = ActionMailer::Base.default_url_options[:host]

    @provider  = FactoryBot.create(:provider_account)
    @buyer     = FactoryBot.create(:buyer_account, provider_account: @provider)
  end

  test 'message_notification has a header to locate the message' do
    message = Message.create! sender: @provider, to: [@buyer]

    notification = PostOffice.message_notification(message, message.recipients.first)
    header = Mail::Header.new(notification.header.encoded)

    assert uri = header['Message-Uri'].value
    assert_equal message, GlobalID::Locator.locate_signed(uri)
  end

  test 'message_notification manage viral footer on email messages' do
    message   = Message.create! sender: @provider, to: [@buyer], subject: 'a message', body: 'W0rmDr1nk'
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now
    email = ActionMailer::Base.deliveries.last

    assert_match email.body, /3scale API/

    @provider.settings.update_attribute :skip_email_engagement_footer_switch, 'visible'

    PostOffice.message_notification(message, recipient).deliver_now
    assert email = ActionMailer::Base.deliveries.last

    assert_equal email.body, 'W0rmDr1nk'
  end

  test 'message_notification from master to provider test send only to admins' do
    FactoryBot.create(:simple_user, account: @provider)
    @provider.reload
    Account.master.update_column(:email_all_users, false)
    message   = Message.create!(:sender => Account.master, :to => [@provider], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal @provider.admins.map(&:email), email.bcc
  end

  test 'message_notification from master to provider should send to all users' do
    FactoryBot.create(:simple_user, account: @provider)
    @provider.reload
    Account.master.update_column(:email_all_users, true)
    message   = Message.create!(:sender => Account.master, :to => [@provider], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal @provider.users.map(&:email), email.bcc
  end

  test 'message_notification from provider to master should send only to admin' do
    FactoryBot.create(:simple_user, account: Account.master)
    Account.master.update_column(:email_all_users, true)
    @provider.reload
    message   = Message.create!(:sender => @provider, :to => [Account.master], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal Account.master.admins.map(&:email), email.bcc
  end

  test 'message_notification from provider to buyer should send only to admin' do
    FactoryBot.create(:simple_user, account: @buyer)
    @provider.update_column(:email_all_users, false)
    @provider.reload
    message   = Message.create!(:sender => @provider, :to => [@buyer], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal @buyer.admins.map(&:email), email.bcc
  end

  test 'message_notification from provider to buyer should send to all users' do
    FactoryBot.create(:simple_user, account: @buyer)
    @provider.update_column(:email_all_users, true)
    @provider.reload
    message   = Message.create!(:sender => @provider, :to => [@buyer], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal @buyer.users.map(&:email), email.bcc
  end

  test 'message_notification from buyer to provider should send only to admin' do
    FactoryBot.create(:simple_user, account: @provider)
    @provider.update_column(:email_all_users, true)
    @provider.reload
    message   = Message.create!(:sender => @buyer, :to => [@provider], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal @provider.admins.map(&:email), email.bcc
  end

  test 'messages sent by the system verify email' do
    message   = Message.create!(:sender => @provider, :to => [@buyer], :subject => 'message', :body => "message")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal message.subject, email.subject
    assert_equal @buyer.admins.map(&:email), email.bcc
    assert_equal [Rails.configuration.three_scale.noreply_email], email.from
  end

  test 'messages sent via web have link to buyer dashboard if sent to buyer' do
    message   = Message.create!(:sender => @provider, :to => [@buyer], :subject => 'buyer', :body => "buyer", :origin => "web")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal "[msg] #{message.subject}", email.subject
    assert_equal @buyer.admins.map(&:email), email.bcc
    assert_equal [Rails.configuration.three_scale.noreply_email], email.from
    assert_match "http://#{@provider.domain}/admin/messages/received", email.body.to_s
  end

  test 'messages sent via web have link to provider dashboard if sent to provider' do
    message   = Message.create!(sender: @buyer, to: [@provider], subject: 'provider', body: "provider", origin: "web")
    recipient = message.recipients.first

    PostOffice.message_notification(message, recipient).deliver_now

    assert email = ActionMailer::Base.deliveries.last
    assert_equal "[msg] #{message.subject}", email.subject
    assert_equal @provider.admins.map(&:email), email.bcc
    assert_equal [Rails.configuration.three_scale.noreply_email], email.from
    assert_match url_helpers.provider_admin_messages_inbox_url(recipient, host: @provider.self_domain), email.body.to_s
  end

  test 'messages sent via web throw better error when :host is missing' do
    message   = Message.create!(sender: @buyer, to: [@provider], subject: 'provider', body: "provider", origin: "web")
    recipient = message.recipients.first

    recipient.receiver.stubs(:self_domain).returns(nil)

    begin
      PostOffice.message_notification(message, recipient).deliver_now
      flunk 'Missing host did not raise'
    rescue ArgumentError => e
      assert_match /^Message\([0-9]+\),Recipient\([0-9]+\)/, e.message
    end
  end

  test 'report should verify email' do
    @account = @provider
    file = Rails.root.join("tmp", "#{@account.domain}.pdf")

    report = Pdf::Report.new @account, @account.first_service!
    file.stubs(:path).returns(file)
    report.stubs(:report).returns(file)

    `touch #{file}`

    PostOffice.report(report, "December 2010").deliver_now
    @email = ActionMailer::Base.deliveries.last

    assert_equal "3scale: #{@account.first_service!.name} - December 2010", @email.subject
    assert_equal [@account.admins.first.email], @email.bcc
    assert_equal [Rails.configuration.three_scale.noreply_email], @email.from
    assert_match "Please find attached your API Usage Report from 3scale.", @email.parts.first.body.to_s
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
