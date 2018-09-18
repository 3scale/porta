require 'spec_helper'

resource "LineItem", transactions: false do
  let(:provider) { Factory(:simple_provider) }
  let(:buyer) { Factory(:simple_buyer, provider_account: provider) }
  let(:application) { Factory(:simple_cinstance, user_account: buyer) }

  let(:invoice) { Factory(:invoice, buyer_account: buyer, provider_account: provider) }

  let(:resource) do
    Factory(:line_item_variable_cost, invoice: invoice,
                           contract: application,
                           name: 'Line item', description: 'desc', quantity: 2, cost: 10, metric_id: 42)
  end

  before { provider.create_billing_strategy! }

  api 'line item' do
    let(:invoice_id) { invoice.id }

    get "api/invoices/:invoice_id/line_items.:format", action: :index
  end

  json(:resource) do
    let(:root) { 'variable_cost' }
    let(:key) { resource }

    it { should have_properties('id', 'name', 'description', 'quantity', 'cost', 'created_at', 'updated_at').from(key) }
    it { should have_properties('type', 'metric_id', 'contract_id', 'contract_type').from(key) }
    it { should have_links('application', 'invoice') }
  end

  json(:collection) do
    let(:root) { 'line_items' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    it('has root') { should have_tag('line-item') }

    context "key" do
      subject { xml.root }

      it { should have_tag('id') }
      it { should have_tag('name') }
      it { should have_tag('description') }
      it { should have_tag('quantity') }
      it { should have_tag('cost') }
      it { should have_tag('metric_id') }
      it { should have_tag('contract_id') }
      it { should have_tag('contract_type') }
      it { should have_tag('plan_id') }
      it { should have_tag('type') }
    end

  end
end

__END__
api_invoice_line_items GET    /api/invoices/:invoice_id/line_items(.:format)  finance/api/line_items#index
