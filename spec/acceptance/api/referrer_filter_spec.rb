require 'rails_helper'

resource "ReferrerFilter" do

  let(:buyer) { FactoryBot.create(:buyer_account, provider_account: provider) }
  let(:application) { FactoryBot.create(:cinstance, user_account: buyer, service: provider.default_service) }

  let(:resource) { ReferrerFilter.create!(application: application, value: 'key-abc') }

  api 'referrer filter' do
    let(:account_id) { buyer.id }
    let(:application_id) { application.id }

    get "/admin/api/accounts/:account_id/applications/:application_id/referrer_filters.:format", action: :index
  end

  json(:resource) do
    let(:root) { 'referrer_filter' }
    let(:key) { resource }

    it { should have_properties('value', 'created_at', 'updated_at').from(key) }
    it { should have_links('application') }
  end

  json(:collection) do
    let(:root) { 'referrer_filters' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    it('has root') { should have_tag('referrer_filter') }

    context "key" do
      subject { xml.root }

      it { should have_tag('id') }
      it { should have_tag('value') }
      it { should have_tag('updated_at') }
      it { should have_tag('created_at') }
    end

  end
end

__END__
admin_api_account_application_keys GET    /admin/api/accounts/:account_id/applications/:application_id/keys(.:format)   admin/api/buyer_application_keys#index {:format=>"xml"}
