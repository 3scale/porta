require 'spec_helper'

resource "PaymentTransaction", transactions: true do

  let(:invoice) { Factory(:invoice, provider_account: provider) }
  let(:resource) do
    Factory(:payment_transaction, invoice: invoice, account: invoice.buyer_account,
                            reference: 'ABC', message: 'bcd', action: 'charge')
  end

  api 'payment transaction' do
    before { provider.create_billing_strategy }

    let(:invoice_id) { invoice.id }
    get '/api/invoices/:invoice_id/payment_transactions.:format', action: :index
  end

  json(:resource) do
    let(:root) { 'payment_transaction' }
    it { should have_properties(%w|id reference success amount currency action message test|).from(resource) }
    it { should have_links('invoice', 'account') }
  end

  json(:collection) do
    let(:root) { 'payment_transactions' }
    it { should be_an(Array) }
  end
end

__END__
api_invoice_payment_transactions GET    /api/invoices/:invoice_id/payment_transactions(.:format)  finance/api/payment_transactions#index
