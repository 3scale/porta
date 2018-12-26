require 'rails_helper'

resource "Service" do

  let(:resource) { FactoryBot.build(:service, account: provider, system_name: 'foobar') }

  before do
    provider.settings.allow_multiple_services!
  end

  api 'service' do
    parameter :name, 'Service Name'

    get "/admin/api/services.:format", action: :index do
      # reload resource because it has been touched
      let(:serializable) { [provider.services.default, resource.reload] }
    end

    get "/admin/api/services/:id.:format", action: :show do
      before { resource.reload }
    end

    post "/admin/api/services.:format", action: :create do
      parameter :name, 'Service Name'
      let(:name) { 'Example service' }
    end

    put "/admin/api/services/:id.:format", action: :update do
      parameter :name, 'Service Name'
      let(:name) { 'some name' }
    end
  end

  xml(:resource) do
    before { resource.save! }

    let(:root) { 'service' }

    it { should have_tag(root) }

    context 'service' do
      subject(:service) { Hash.from_xml(serialized).fetch(root) }
      it { should include('id' => resource.id.to_s, 'system_name' => resource.system_name) }
    end
  end

  json(:resource) do
    before { resource.save! }

    let(:root) { 'service' }

    it { should include('id' => resource.id, 'system_name' => resource.system_name) }
    it { should have_links(%w|self end_user_plans service_plans application_plans features metrics|)}
  end

  json(:collection) do
    let(:root) { 'services' }
    it { should be_an(Array) }
  end
end

__END__

admin_api_services GET    /admin/api/services(.:format)      admin/api/services#index {:format=>"xml"}
                   POST   /admin/api/services(.:format)      admin/api/services#create {:format=>"xml"}
 admin_api_service GET    /admin/api/services/:id(.:format)  admin/api/services#show {:format=>"xml"}
                   PUT    /admin/api/services/:id(.:format)  admin/api/services#update {:format=>"xml"}
                   DELETE /admin/api/services/:id(.:format)  admin/api/services#destroy {:format=>"xml"}
