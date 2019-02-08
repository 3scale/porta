require 'test_helper'

class ProviderUserMailerTest < ActionMailer::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
  end

  class ProviderTest < ProviderUserMailerTest
    def setup
      @support_email_address = Mail::Address.new(ThreeScale.config.support_email).address
    end

    class ProviderSaasTest < ProviderTest
      # ThreeScale.config.onpremises should be false by default

      test 'activation' do
        ProviderUserMailer.activation(user).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal 'Account Activation', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Signup Notification"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{Dear #{user.informal_name}}, email_body
        assert_match %r{Thank you for signing up to Red Hat 3scale}, email_body
        assert_match %r{#{account.admin_domain}/p/activate/[a-z0-9]+}, email_body
        assert_match %r{The Red Hat 3scale Team}, email_body
      end

      test 'activation reminder' do
        ProviderUserMailer.activation_reminder(user).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal 'Account Activation Reminder', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Signup Notification"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{#{user.informal_name}}, email_body
        assert_match %r{A couple of days ago you signed up for Red Hat 3scale to manage your API}, email_body
        assert_match %r{#{account.admin_domain}/p/activate/[a-z0-9]+}, email_body
        assert_match %r{The Red Hat 3scale Team}, email_body
      end

      test 'lost_domain' do
        ProviderUserMailer.lost_domain('the.one.who.forgets@example.com', [account.domain]).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal ['the.one.who.forgets@example.com'], email.to
        assert_equal 'Domain Recovery', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Domain Recovery"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{Dear User}, email_body
        assert_match %r{https://#{account.domain}/p/login}, email_body
        assert_match %r{The Red Hat 3scale Team}, email_body
      end

      test 'lost_password' do
        ProviderUserMailer.lost_password(user).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal 'Password Recovery', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Lost password"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{Dear #{user.display_name}}, email_body
        assert_match %r{You can reset your password by visiting the following link}, email_body
        assert_match %r{#{account.admin_domain}/p/password}, email_body
        assert_match %r{The Red Hat 3scale Team}, email_body
      end
    end

    class ProviderOnpremTest < ProviderTest
      def setup
        ThreeScale.config.stubs(onpremises: true)
        @support_email_address = Mail::Address.new(ThreeScale.config.support_email).address
      end

      test 'activation' do
        ProviderUserMailer.activation(user).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal 'Account Activation', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Signup Notification"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{Dear #{user.informal_name}}, email_body
        assert_match %r{Thank you for signing up to #{master_account.org_name}}, email_body
        assert_match %r{#{account.admin_domain}/p/activate/[a-z0-9]+}, email_body
        assert_match %r{The #{master_account.org_name} Team}, email_body
        refute_match %r{/3scale|redhat/i}, email_body
      end

      test 'activation reminder' do
        ProviderUserMailer.activation_reminder(user).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal 'Account Activation Reminder', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Signup Notification"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{#{user.informal_name}}, email_body
        assert_match %r{A couple of days ago you signed up for #{master_account.org_name} to manage your API}, email_body
        assert_match %r{#{account.admin_domain}/p/activate/[a-z0-9]+}, email_body
        assert_match %r{The #{master_account.org_name} Team}, email_body
        refute_match %r{/3scale|redhat/i}, email_body
      end

      test 'lost_domain' do
        ProviderUserMailer.lost_domain('the.one.who.forgets@example.com', [account.domain]).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal ['the.one.who.forgets@example.com'], email.to
        assert_equal 'Domain Recovery', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Domain Recovery"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{Dear User}, email_body
        assert_match %r{https://#{account.domain}/p/login}, email_body
        assert_match %r{The #{master_account.org_name} Team}, email_body
        refute_match %r{/3scale|redhat/i}, email_body
      end

      test 'lost_password' do
        ProviderUserMailer.lost_password(user).deliver_now
        email = ActionMailer::Base.deliveries.last
        email_body = email.body.to_s

        assert_equal 'Password Recovery', email.subject
        assert_equal [@support_email_address], email.from
        assert_equal '{"category": "Lost password"}', email.header_fields.find{ |header| header.name.eql? 'X-SMTPAPI' }.value

        assert_match %r{Dear #{user.display_name}}, email_body
        assert_match %r{You can reset your password by visiting the following link}, email_body
        assert_match %r{#{account.admin_domain}/p/password}, email_body
        assert_match %r{The #{master_account.org_name} Team}, email_body
        refute_match %r{/3scale|redhat/i}, email_body
      end

      test 'lost password under https' do
        with_default_url_options protocol: 'https' do
          user.stubs lost_password_token: 'abc123'
          ProviderUserMailer.lost_password(user).deliver_now
          email = ActionMailer::Base.deliveries.last
          assert_match "https://#{account.admin_domain}/p/password?password_reset_token=abc123", email.body.to_s
        end
      end
    end

    private

    def with_default_url_options(options)
      ActionMailer::Base.stubs default_url_options: options
      yield
      ActionMailer::Base.unstub :default_url_options
    end

    def user
      @user ||= create_user
    end

    def account
      @account ||= create_account
    end

    def create_user
      FactoryBot.create(:admin, account: account, first_name: 'Jolly Good', last_name: 'Fellow')
    end

    def create_account
      FactoryBot.create(:provider_account, provider_account: master_account, domain: 'api.monkey.com', org_name: 'Monkey', self_domain: 'monkey-admin.com', from_email: 'api@monkey.com', subdomain: 'monkey')
    end
  end

  class MasterTest < ProviderUserMailerTest

    test 'master user activation on saas' do
      ProviderUserMailer.activation(user).deliver_now
      assert_match %r{#{account.admin_domain}/p/activate/[a-z0-9]+}, ActionMailer::Base.deliveries.last.body.to_s
    end

    test 'master user activation on-prem' do
      ThreeScale.config.stubs(onpremises: true)
      ProviderUserMailer.activation(user).deliver_now
      assert_match %r{#{account.admin_domain}/p/activate/[a-z0-9]+}, ActionMailer::Base.deliveries.last.body.to_s
    end

    private

    def user
      @user ||= master_account.admin_users.first
    end

    def account
      master_account
    end
  end

end
