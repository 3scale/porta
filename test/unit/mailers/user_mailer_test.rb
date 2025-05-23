# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
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

  class BuyerTest < UserMailerTest
    setup do
      @provider_account = FactoryBot.create(:provider_account, domain: 'api.monkey.com',
                                                               org_name: "Monkey",
                                                               from_email: 'api@monkey.com')
      @buyer_account = FactoryBot.create(:buyer_account_with_pending_user, provider_account: @provider_account)
      @user = FactoryBot.create(:admin, account: @buyer_account)
    end

    class SignUpNotificationForBuyerTest < BuyerTest
      test "should have specific headers" do
        email = deliver_signup_notification

        assert_equal [@provider_account.from_email], email.from
        assert_equal "Monkey API account confirmation", email.subject
        assert_equal [@user.email], email.to
        assert_nil email.bcc
      end

      test "should have specific body" do
        with_default_url_options protocol: 'https' do
          email = deliver_signup_notification

          assert_match "Dear #{user_decorator.display_name},", email.body.to_s
          assert_match "Thank you for signing up for access to the Monkey API", email.body.to_s
          assert_match "Your username is: #{@user.username}", email.body.to_s
          assert_match "https://api.monkey.com/activate/#{@user.activation_code}", email.body.to_s
          assert_match "The API Teams at Monkey", email.body.to_s
        end
      end

      test "should have specific body when provider has custom templates" do
        content = <<~MSG
          Customized Template
          {{ user.display_name }}
          {{ url }}
          {{ provider.name }}
        MSG

        @user.account.provider_account.email_templates.create!(system_name: "signup_notification_email", published: content)

        email = deliver_signup_notification

        assert_match "Customized Template", email.body.to_s
        assert_match user_decorator.display_name, email.body.to_s
        assert_match "Monkey", email.body.to_s
        assert_match "http://api.monkey.com/activate/#{@user.activation_code}", email.body.to_s
      end

      test "should have specific body and subject" do
        UserMailer.signup_notification(@user).deliver_now
        message = ActionMailer::Base.deliveries.last

        # Headers
        assert_equal [@provider_account.from_email], message.from
        assert_equal "Monkey API account confirmation", message.subject

        assert_equal [@user.email], message.to
        assert_nil message.bcc
        assert_match "Thank you for signing up for access to the Monkey API, your account has been created", message.body.to_s
      end
    end

    class LostPasswordTest < BuyerTest
      setup do
        @user.lost_password_token = 'abc123'
      end

      test "should have specific header" do
        email = deliver_lost_password

        assert_match "Lost password recovery", email.subject
        assert_equal [@user.email], email.to
        assert_equal ['api@monkey.com'], email.from
      end

      test 'should have specific body' do
        with_default_url_options protocol: 'https' do
          email = deliver_lost_password
          assert_match "You can reset your password by visiting the following link", email.body.to_s
          assert_match "https://#{@provider_account.external_domain}/admin/account/password?password_reset_token=abc123", email.body.to_s
        end
      end

      test "custom template should have specific body when provider has custom templates" do
        content = <<-MSG
        Dear {{ user.display_name }},

        CUSTOM MESSAGES

        {{ url }}

        The API Team.
        MSG

        @user.account.provider_account.email_templates.create!(system_name: "lost_password_email", published: content)

        email = deliver_lost_password
        # assert_match "CUSTOM SUBJECT", email.subject
        assert_match "Lost password recovery", email.subject
        assert_match "Dear #{user_decorator.display_name},", email.body.to_s
        assert_match "CUSTOM MESSAGE", email.body.to_s
        assert_match "http://#{@provider_account.external_domain}/admin/account/password?password_reset_token=abc123", email.body.to_s
        assert_match "The API Team", email.body.to_s
      end
    end
  end

  def user_decorator
    @user_decorator ||= @user.decorate
  end

  def with_default_url_options(options)
    ActionMailer::Base.stubs default_url_options: options
    yield
  end
end
