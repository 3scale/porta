require 'rails_helper'
require 'will_paginate/array'

resource "Invoice", transactions: false do

  let(:buyer) { FactoryBot.create(:buyer_account, provider_account: provider) }
  let(:resource) { FactoryBot.create(:invoice, buyer_account: buyer, provider_account: provider) }

  let(:collection) { [resource].paginate(page: 1, per_page: 20) }
  let(:account_id) { buyer.id }

  before { provider.create_billing_strategy! }

  api 'invoices' do
    get '/api/invoices.:format', action: :index
    get '/api/invoices/:id.:format', action: :show
    post '/api/invoices/:id/charge.:format', action: :charge
  end

  api 'account invoices' do
    get '/api/accounts/:account_id/invoices.:format', action: :index
    get '/api/accounts/:account_id/invoices/:id.:format', action: :show
  end

  api 'set invoice state' do
    let(:id) { resource.id }

    put '/api/invoices/:id/state.:format' do
      include_context "resource"

      parameter :state, "The destination state you want to transit."
      let(:state){'cancel'}
      request "Set State" do
        resource.reload.state.should == 'cancelled'
      end
    end
  end

  json(:resource) do
    let(:root) { 'invoice' }
    it { should include('id' => resource.id, 'friendly_id' => resource.friendly_id, 'state' => resource.state) }
    it { should include('cost', 'currency', 'period') }
    it { should have_links('self', 'account', 'payment_transactions', 'line_items') }

    # TODO: make it check for paid at and others (in nested context)
    # should include('paid_at', 'due_on', 'issued_on', 'currency', 'cost')

    context 'when cost > 0' do
      before { FactoryBot.create(:line_item, cost: 100, invoice: resource) }

      context 'vat_rate is nil' do
        it { should include('cost' => 100.0, 'vat_rate' => nil, 'vat_amount' => 0.0, 'cost_without_vat' => 100.0) }
      end

      context 'vat_rate == 0' do
        before {
          resource.vat_rate = 0.0
          resource.save!
        }

        it { should include('cost' => 100.0, 'vat_rate' => 0.0, 'vat_amount' => 0.0, 'cost_without_vat' => 100.0) }
      end

      context 'vat_rate > 0' do
        before {
          resource.vat_rate = 10.0
          resource.save!
        }

        it { should include('cost' => 110.0, 'vat_rate' => 10.0, 'vat_amount' => 10.0, 'cost_without_vat' => 100.0) }
      end
    end

  end

  json(:collection) do
    let(:root) { 'invoices' }
    it { should be_an(Array) }
  end
end

__END__

        api_invoices GET    /api/invoices(.:format)                          finance/api/invoices#index
         api_invoice GET    /api/invoices/:id(.:format)                      finance/api/invoices#show
  charge_api_invoice POST   /api/invoices/:id/charge(.:format)               finance/api/invoices#charge
api_account_invoices GET    /api/accounts/:account_id/invoices(.:format)     finance/api/accounts/invoices#index
 api_account_invoice GET    /api/accounts/:account_id/invoices/:id(.:format) finance/api/accounts/invoices#show
