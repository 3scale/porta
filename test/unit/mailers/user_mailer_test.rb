require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def setup
    ActionMailer::Base.deliveries = []
  end

  def deliver_lost_password
    UserMailer.lost_password(@user).deliver_now
    ActionMailer::Base.deliveries.last
  end

  def deliver_signup_notification
    UserMailer.signup_notification(@user).deliver_now
    ActionMailer::Base.deliveries.last
  end

  context "lost_password" do

    setup do
      @provider_account = FactoryBot.create(:provider_account,
                                  :domain     => 'api.monkey.com',
                                  :org_name   => "Monkey",
                                  :from_email => 'api@monkey.com')

      @user = @provider_account.admins.first
      @user.lost_password_token = 'abc123'
      @noreply_email_address = Mail::Address.new(ThreeScale.config.noreply_email).address
    end

    should "have specific header" do
      email = deliver_lost_password

      assert_match "Lost password recovery", email.subject
      assert_equal [@user.email], email.to
      assert_equal [@noreply_email_address], email.from
    end

    should 'have specific body hello' do
      with_default_url_options protocol: 'https' do
        email = deliver_lost_password
        assert_match "You can reset your password by visiting the following link", email.body.to_s
        assert_match "https://#{@provider_account.admin_domain}/p/password?password_reset_token=abc123", email.body.to_s
      end
    end

    context "custom template" do

      setup do
        content = <<-MSG
        Dear {{ user.display_name }},

        CUSTOM MESSAGES

        {{ url }}

        The API Team.
        MSG

        @user.account.provider_account.email_templates.create!(:system_name => "lost_password_email", :published => content)

      end

      should "have specific body when provider has custom templates" do

        email = deliver_lost_password
        # assert_match "CUSTOM SUBJECT", email.subject
        assert_match "Lost password recovery", email.subject
        assert_match "Dear #{@user.display_name},", email.body.to_s
        assert_match "CUSTOM MESSAGE", email.body.to_s
        assert_match "http://#{@provider_account.admin_domain}/p/password?password_reset_token=abc123", email.body.to_s
        assert_match "The API Team", email.body.to_s

      end

    end


  end


  context "signup_notification" do
    context "for buyer" do
      setup do
        @provider_account = FactoryBot.create(:provider_account,
                                    :domain     => 'api.monkey.com',
                                    :org_name   => "Monkey",
                                    :from_email => 'api@monkey.com')

        @buyer_account = FactoryBot.create(:buyer_account_with_pending_user,
                                 :provider_account => @provider_account)

        @user = FactoryBot.create :admin, :account => @buyer_account
      end

      should "have specific headers" do

        email = deliver_signup_notification

        assert_equal [@provider_account.from_email], email.from
        assert_equal "Monkey API account confirmation", email.subject
        assert_equal [@user.email], email.to
        assert_nil email.bcc
      end

      should "have specific body" do
        with_default_url_options protocol: 'https' do
          email = deliver_signup_notification

          assert_match "Dear #{@user.display_name},", email.body.to_s
          assert_match "Thank you for signing up for access to the Monkey API", email.body.to_s
          assert_match "Your username is: #{@user.username}", email.body.to_s
          assert_match "https://api.monkey.com/activate/#{@user.activation_code}", email.body.to_s
          assert_match "The API Teams at Monkey and 3scale", email.body.to_s
        end
      end

      should "have specific body when provider has custom templates" do
        content = <<-MSG
Customized Template
{{ user.display_name }}
{{ url }}
{{ provider.name }}
        MSG

        @user.account.provider_account.email_templates.create!(:system_name => "signup_notification_email",
                                                         :published => content)

        email = deliver_signup_notification

        assert_match "Customized Template", email.body.to_s
        assert_match @user.display_name, email.body.to_s
        assert_match "Monkey", email.body.to_s
        assert_match "http://api.monkey.com/activate/#{@user.activation_code}", email.body.to_s
      end

      should "have specific body and subject" do
        UserMailer.signup_notification(@user).deliver_now
        message = ActionMailer::Base.deliveries.last

        # Headers
        assert_equal [@provider_account.from_email], message.from
        assert_equal "Monkey API account confirmation", message.subject

        assert_equal [@user.email], message.to
        assert_nil message.bcc
        assert_match "Thank you for signing up for access to the Monkey API, your account has been created", message.body.to_s
      end

      context "lost_password" do

        setup do
          @user.lost_password_token = 'abc123'
        end

        should "have specific header" do
          email = deliver_lost_password

          assert_match "Lost password recovery", email.subject
          assert_equal [@user.email], email.to
          assert_equal ['api@monkey.com'], email.from
        end

        should 'have specific body' do
          with_default_url_options protocol: 'https' do
            email = deliver_lost_password
            assert_match "You can reset your password by visiting the following link", email.body.to_s
            assert_match "https://#{@provider_account.domain}/admin/account/password?password_reset_token=abc123", email.body.to_s
          end
        end

        context "custom template" do

          setup do
            content = <<-MSG
        Dear {{ user.display_name }},

        CUSTOM MESSAGES

        {{ url }}

        The API Team.
            MSG

            @user.account.provider_account.email_templates.create!(:system_name => "lost_password_email", :published => content)

          end

          should "have specific body when provider has custom templates" do

            email = deliver_lost_password
            # assert_match "CUSTOM SUBJECT", email.subject
            assert_match "Lost password recovery", email.subject
            assert_match "Dear #{@user.display_name},", email.body.to_s
            assert_match "CUSTOM MESSAGE", email.body.to_s
            assert_match "http://#{@provider_account.domain}/admin/account/password?password_reset_token=abc123", email.body.to_s
            assert_match "The API Team", email.body.to_s

          end

        end


      end
    end
  end

  def with_default_url_options(options)
    ActionMailer::Base.stubs default_url_options: options
    yield
  end
end
