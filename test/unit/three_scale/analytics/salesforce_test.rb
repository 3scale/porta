require 'test_helper'

class ThreeScale::Analytics::SalesforceTest < ActiveSupport::TestCase

  def setup
    @provider = Account.providers.new
    @provider.id = 42

    @segment = mock('segment')
    @salesforce = ThreeScale::Analytics::Salesforce.new(@provider, @segment)
  end

  def test_segment_context
    context = @salesforce.segment_context

    assert_equal({Salesforce: {object: 'MT_Account__c', lookup: {accountNumber: 42}}}, context[:context])
    assert_equal({Salesforce: true, all: false}, context[:integrations])
  end

  def test_segment
    salesforce = ThreeScale::Analytics::Salesforce.new(@provider)
    assert salesforce.segment
  end

  def test_update_invoice_status
    plan = ApplicationPlan.new
    plan.id = 123456789
    plan.name = 'Power'

    @provider.self_domain = 'domain-admin.example.com'
    @provider.stubs(bought_plan: plan, currency: 'USD')

    invoice = Invoice.new
    invoice.id = 6789
    invoice.provider_account = @provider
    invoice.currency = 'USD'
    invoice.friendly_id = '2015-10-01-00001'

    # FFS, consistency!
    invoice.issued_on = Time.utc(2015, 8, 13, 1, 1)
    invoice.due_on = Time.utc(2015, 8, 14, 1, 1)
    invoice.paid_at = Time.utc(2015, 8, 15, 1, 1)

    invoice.state = 'paid'

    traits = {
        account_id: 42,
        self_domain: 'domain-admin.example.com',
        plan: 'Power',
        plan_id: 123456789,
        payment_amount: 0.0,
        payment_currency: 'USD',
        invoice_number: 6789,
        invoice_human_number: '2015-10-01-00001',
        invoice_issued: invoice.issued_on,
        invoice_paid: invoice.paid_at,
        invoice_due_on: invoice.due_on,
        invoice_status: 'paid'
    }

    # {"userId":42,"anonymousId":null,"integrations":{"Salesforce":true},"context":{"Salesforce":{"object":"MT_Account__c","lookup":{"accountNumber":42}},"library":{"name":"analytics-ruby","version":"2.0.12"}},"traits":{"account_id":42,"self_domain":"domain-admin.example.com","plan":"Power","plan_id":123456789,"payment_amount":150.0,"payment_currency":"USD","invoice_number":6789,"invoice_issued":"2015-08-13T01:01:00.000Z","invoice_paid":"2015-08-15T01:01:00.000Z","invoice_status":"paid"},"options":null,"timestamp":"2015-08-19T16:31:56.131+02:00","type":"identify","messageId":"a5609634-13e7-4ca9-9014-a13b544419ad"}
    @segment.expects(:identify).with(user_id: 42, traits: traits, **@salesforce.segment_context)



    @salesforce.update_invoice_status(invoice)
  end
end
