module ThreeScale
  module Analytics
    class Salesforce

      Segment = ThreeScale::Analytics::UserTracking::Segment

      attr_reader :provider, :segment

      def initialize(provider, segment = Segment)
        @provider = provider
        @segment = segment
      end

      def update_invoice_status(invoice)
        bought_plan = @provider.bought_plan

        traits = {
            account_id: @provider.id,
            self_domain: @provider.self_domain,

            plan: bought_plan.name,
            plan_id: bought_plan.id,

            payment_amount: invoice.cost.amount,
            payment_currency: invoice.cost.currency,

            invoice_number: invoice.id,
            invoice_human_number: invoice.friendly_id,
            invoice_issued: invoice.issued_on,
            invoice_paid: invoice.paid_at,
            invoice_due_on: invoice.due_on,
            invoice_status: invoice.state
        }

        @segment.identify(user_id: @provider.id, traits: traits, **segment_context)
      end

      def segment_context
        {
            integrations: {
                all: false,
                Salesforce: true
            },
            context: {
                Salesforce: {
                    object: 'MT_Account__c',
                    lookup: {accountNumber: provider.id}
                }
            }
        }
      end
    end
  end
end
