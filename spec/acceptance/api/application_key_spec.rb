require 'spec_helper'

resource "ApplicationKey" do

  let(:buyer) { Factory(:buyer_account, provider_account: provider) }
  let(:application) { Factory(:cinstance, user_account: buyer, service: provider.default_service) }

  let(:resource) { ApplicationKey.create!(application: application, value: 'key-abc') }

  api 'application key' do
    let(:account_id) { buyer.id }
    let(:application_id) { application.id }
    get "/admin/api/accounts/:account_id/applications/:application_id/keys.:format", action: :index
  end

  json(:resource) do
    let(:root) { 'key' }
    let(:key) { resource }

    it { should have_properties('value', 'created_at', 'updated_at').from(key) }
    it { should have_links('application') }
  end

  json(:collection) do
    let(:root) { 'keys' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    it('has root') { should have_tag('key') }

    context "key" do
      subject { xml.root }

      it { should have_tag('value') }
      it { should have_tag('updated_at') }
      it { should have_tag('created_at') }
    end

  end
end

__END__
admin_api_account_application_keys GET    /admin/api/accounts/:account_id/applications/:application_id/keys(.:format)   admin/api/buyer_application_keys#index {:format=>"xml"}
