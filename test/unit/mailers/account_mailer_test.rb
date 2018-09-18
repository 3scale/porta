require 'test_helper'

class AccountMailerTest < ActionMailer::TestCase

  def setup
    @account = FactoryGirl.create(:buyer_account)
  end

  test 'send mails' do
    AccountMailer.confirmed(@account).deliver_now!
    AccountMailer.approved(@account).deliver_now!
    AccountMailer.rejected(@account).deliver_now!
    assert_equal 3, ActionMailer::Base.deliveries.count
  end

  class SupportEntitlements < ActionMailer::TestCase
    setup do
      ThreeScale.config.redhat_customer_portal.stubs(assign_entitlements_email: 'assign.entitlements@example.com')
      ThreeScale.config.redhat_customer_portal.stubs(revoke_entitlements_email: 'revoke.entitlements@example.com')

      @service = FactoryGirl.create(:service, account: master_account)

      account_data = {
        org_name: 'Fake Provider',
        billing_address_first_name: 'John',
        billing_address_last_name: 'Doe',
        billing_address_address1: '123 Any Fake Rd',
        billing_address_address2: 'Suite 10',
        billing_address_city: 'Far Away',
        billing_address_state: 'Nice Province',
        billing_address_zip: '12345',
        billing_address_country: 'US',
        billing_address_phone: '+123 456 789',
        finance_support_email: 'john.doe@fake.example.com'
      }
      @account = FactoryGirl.create(:simple_provider, account_data)

      FactoryGirl.create(:simple_admin, account: @account, username: 'john_doe')

      @invoice = FactoryGirl.create(:invoice, issued_on: Time.parse('2017-11-16'))
    end

    def test_support_entitlements_assigned
      @account.buy! Factory(:application_plan, issuer: @service, cost_per_month: 50)

      mail = AccountMailer.support_entitlements_assigned(@account, effective_since: @invoice.issued_on, invoice_id: @invoice.id)

      assert_equal '3scale Notification - Assign Entitlements', mail.subject
      assert_equal [master_account.from_email], mail.from
      assert_equal ['assign.entitlements@example.com'], mail.to

      body = mail.body.encoded
      redhat_login = @account.field_value('red_hat_account_number').presence

      assert_match "RHLogin: #{redhat_login}", body
      assert_match "Invoice ID: #{@invoice.id}", body
      assert_match "Sku: MCT3712 (Basic Plus Support)", body
      assert_match "Qty: 1", body
      assert_match "Effective: 16 November, 2017", body
      assert_match "First name: John", body
      assert_match "Last name: Doe", body
      assert_match "User name: john_doe", body
      assert_match "Email address: john.doe@fake.example.com", body
      assert_match "Organization Name: Fake Provider", body
      assert_match "Address1: 123 Any Fake Rd", body
      assert_match "Address2: Suite 10", body
      assert_match "City: Far Away", body
      assert_match "Region: Nice Province", body
      assert_match "Postal Code: 12345", body
      assert_match "Country: US", body
      assert_match "Phone: +123 456 789", body
    end

    def test_support_entitlements_trial_plan
      trial_plan = Factory(:application_plan, issuer: @service)
      trial_plan.plan_rule.metadata = {trial: true}
      @account.buy! trial_plan

      Timecop.freeze(Date.new(2017, 11, 21)) do
        mail = AccountMailer.support_entitlements_assigned(@account)

        assert_equal '3scale Notification - Assign Entitlements', mail.subject
        assert_equal [master_account.from_email], mail.from
        assert_equal ['assign.entitlements@example.com'], mail.to

        body = mail.body.encoded
        redhat_login = @account.field_value('red_hat_account_number').presence

        assert_match "RHLogin: #{redhat_login}", body
        assert_match "Invoice ID: n/a", body
        assert_match "Sku: SER0541 (90 Day Supported Eval)", body
        assert_match "Qty: 1", body
        assert_match "Effective: 21 November, 2017", body
        assert_match "First name: John", body
        assert_match "Last name: Doe", body
        assert_match "User name: john_doe", body
        assert_match "Email address: john.doe@fake.example.com", body
        assert_match "Organization Name: Fake Provider", body
        assert_match "Address1: 123 Any Fake Rd", body
        assert_match "Address2: Suite 10", body
        assert_match "City: Far Away", body
        assert_match "Region: Nice Province", body
        assert_match "Postal Code: 12345", body
        assert_match "Country: US", body
        assert_match "Phone: +123 456 789", body
      end
    end

    def test_support_entitlements_revoked
      mail = AccountMailer.support_entitlements_revoked(@account, effective_since: @invoice.issued_on, invoice_id: @invoice.id)

      assert_equal '3scale Notification - Revoke Entitlements', mail.subject
      assert_equal [master_account.from_email], mail.from
      assert_equal ['revoke.entitlements@example.com'], mail.to

      body = mail.body.encoded
      redhat_login = @account.field_value('red_hat_account_number').presence

      assert_match "RHLogin: #{redhat_login}", body
      assert_match "Invoice ID: #{@invoice.id}", body
      assert_match "Sku: Terminate current SKU", body
      assert_match "Qty: 0", body
      assert_match "Effective: 16 November, 2017", body
      assert_match "First name: John", body
      assert_match "Last name: Doe", body
      assert_match "User name: john_doe", body
      assert_match "Email address: john.doe@fake.example.com", body
      assert_match "Organization Name: Fake Provider", body
      assert_match "Address1: 123 Any Fake Rd", body
      assert_match "Address2: Suite 10", body
      assert_match "City: Far Away", body
      assert_match "Region: Nice Province", body
      assert_match "Postal Code: 12345", body
      assert_match "Country: US", body
      assert_match "Phone: +123 456 789", body
    end
  end
end
