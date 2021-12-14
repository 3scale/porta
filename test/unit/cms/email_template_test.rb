# frozen_string_literal: true

require 'test_helper'

class EmailTemplateTest < ActiveSupport::TestCase
  def setup
    @subject = "subject"
    @bcc = "bcc@mail.example.com"
    @cc = "cc@mail.example.com"
    @custom = "CUSTOM"
    @tags = %(\
{% email %}
  {% subject "Subject!" %}
  {% bcc = "alias <bcc@mail.example.com>" "another <alias@mail.example.com>" %}
  {% header 'X-Custom' = 'X-Value' %}
{% endemail %}\
)
  end

  test 'save headers' do
    saved = CMS::EmailTemplate.create!(system_name: 'system_name', published: 'text',
                                                                   provider: FactoryBot.create(:provider_account),
                                                                   headers: { key: 'value' })
    loaded = saved.class.find(saved.id)

    assert_equal saved.headers, loaded.headers
    assert_equal saved.headers.key, loaded.headers.key
  end

  test 'serialize headers as Hash' do
    headers = {"subject"=>"Text Analysis API - New key created", "bcc"=>"", "cc"=>"", "reply_to"=>"", "from"=>"AYLIEN"}
    template = CMS::EmailTemplate.create!(system_name: 'system_name', published: 'text', provider: FactoryBot.create(:simple_account))
    template.update_column :options, headers # rubocop:disable Rails/SkipsModelValidations Testing it does not raise if we do `update_column` with simple Hash
    assert_equal headers, template.options
  end

  test 'serialize headers as ActionController::Parameters' do
    headers = {"subject"=>"Text Analysis API - New key created", "bcc"=>"", "cc"=>"", "reply_to"=>"", "from"=>"AYLIEN"}
    params = ActionController::Parameters.new(headers)
    template = CMS::EmailTemplate.create!(system_name: 'system_name', published: 'text', provider: FactoryBot.create(:simple_account))
    template.update_column :options, params # rubocop:disable Rails/SkipsModelValidations Testing it does not raise if we `update_column` with unpermitted parameters
    template.reload
    assert_equal headers, template.options
  end

  test 'serialized ActionController::Parameters `options` loads correctly' do
    headers = {"subject"=>"Text Analysis API - New key created", "bcc"=>"", "cc"=>"", "reply_to"=>"", "from"=>"AYLIEN"}
    params = ActionController::Parameters.new(headers)
    template = CMS::EmailTemplate.create! system_name: 'system_name', published: 'text',
      provider: FactoryBot.create(:simple_account)
    yaml = YAML.dump(params)
    template.update_column :options, yaml # rubocop:disable Rails/SkipsModelValidations Testing it does not raise if we `update_column` with unpermitted parameters
    template.reload
    assert_equal yaml, template.options_before_type_cast
  end

  test 'comma separated emails in headers are valid' do
    template = FactoryBot.build(:cms_email_template)
    template.headers = {
      bcc: 'email@address.example.com, email@address.example.com',
      cc: 'email@address.example.com, email@address.example.com',
      reply_to: 'email@address.example.com, email@address.example.com',
    }

    assert template.valid?
  end

  test 'validates email format' do
    template = FactoryBot.build(:cms_email_template)
    template.headers = {
      bcc: 'email@address.example.com and some other stuff'
    }
    assert template.invalid?
  end

  test 'validates headers' do
    template = FactoryBot.build(:cms_email_template)
    template.headers = {
      bcc: 'bcc',
      cc: 'email@address.example.com',
    }

    assert template.invalid?
    assert template.errors['headers.bcc'].presence
  end

  test "Account Messenger expired_credit_card_notification_for_buyer should assign headers to messenger" do
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @body = "more awesome content"
    @template = CMS::EmailTemplate.create!(system_name: 'account_messenger_expired_credit_card_notification_for_buyer', published: @body,
                                                                                                                        provider: @provider,
                                                                                                                        headers: {
                                                                                                                          bcc: @bcc,
                                                                                                                          cc: @cc,
                                                                                                                          subject: @subject,
                                                                                                                          custom: @custom
                                                                                                                        })
    message = AccountMessenger.expired_credit_card_notification_for_buyer(@buyer) && Message.last

    assert_equal("more awesome content", message.body)
    assert_equal({"cc"=>@cc, "bcc"=>@bcc, "custom"=>@custom}, message.headers)
    assert_equal(@subject, message.subject)
  end

  test "Account Messenger expired_credit_card_notification_for_buyer with headers should assign headers to messenger" do
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @body = "more awesome content"
    @template = CMS::EmailTemplate.create!(system_name: 'account_messenger_expired_credit_card_notification_for_buyer', published: @body,
                                                                                                                        provider: @provider,
                                                                                                                        headers: {
                                                                                                                          bcc: @bcc,
                                                                                                                          cc: @cc,
                                                                                                                          subject: @subject,
                                                                                                                          custom: @custom
                                                                                                                        })
    @template.published = @tags + @template.published
    @template.save!
    message = AccountMessenger.expired_credit_card_notification_for_buyer(@buyer) && Message.last

    assert_equal("Subject!", message.subject)
    assert_equal("more awesome content", message.body)
    assert_equal({ "cc"=>@cc,
                   "bcc"=>["alias <bcc@mail.example.com>", "another <alias@mail.example.com>"],
                   "custom"=>@custom,
                   'X-Custom' => 'X-Value' }, message.headers)
  end

  # this is to check we can override template of message send to provider to buyer
  test "Account Messenger New Signup template should assign headers to messenger" do
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @body = "awesome content"
    @template = CMS::EmailTemplate.create!(system_name: 'account_messenger_new_signup', published: @body,
                                                                                        provider: @provider,
                                                                                        headers: {
                                                                                          bcc: @bcc,
                                                                                          cc: @cc,
                                                                                          subject: @subject,
                                                                                          custom: @custom
                                                                                        })
    message = AccountMessenger.new_signup(@buyer) && Message.last

    assert_equal("awesome content", message.body)
  end

  test "Account Approved template should assign headers to mailer" do
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @body = "My content"
    @template = CMS::EmailTemplate.create!(system_name: 'account_approved', published: @body,
                                                                            provider: @provider,
                                                                            headers: {
                                                                              bcc: @bcc,
                                                                              cc: @cc,
                                                                              subject: @subject,
                                                                              custom: @custom
                                                                            })
    @template.published = @tags + @template.published
    @template.save!

    mail = AccountMailer.approved(@buyer)

    assert_equal "Subject!", mail.subject
    assert_match 'My content', mail.body.to_s
    assert_equal "alias <bcc@mail.example.com>, another <alias@mail.example.com>", mail.header['bcc'].to_s
    assert_equal "cc@mail.example.com", mail.header['cc'].to_s
    assert_equal @custom, mail.header['custom'].to_s

    mail.deliver_now

    assert_match /poweredby/, mail.body.to_s
  end

  test 'all new and overriden' do
    provider = FactoryBot.create(:provider_account)

    assert provider.provider_can_use?(:new_notification_system)

    templates = provider.email_templates.all_new_and_overridden.map(&:system_name)
    assert_equal CMS::EmailTemplate::BUYER_BILLING_TEMPLATES.sort, (templates & CMS::EmailTemplate::BUYER_BILLING_TEMPLATES).sort

    ThreeScale.config.stubs(onpremises: true)
    provider.stubs(master?: true)
    templates = provider.email_templates.all_new_and_overridden.map(&:system_name)
    assert_empty templates & CMS::EmailTemplate::BUYER_BILLING_TEMPLATES
  end
end
