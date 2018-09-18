require 'spec_helper'

resource "ApiDocs::Service" do

  let(:resource) do 
    ApiDocs::Service.create(account: provider, body: '{"basePath":"https://microsoft.co.uk", "apis":[]}', description: 'desc',
                                           name: 'some-api-doc', system_name: 'some-api-doc') 
  end

  api 'api docs' do
    put '/admin/api/active_docs/:id.:format', action: :update do
      let(:id) { resource.id }

      parameter :body, 'JSON Spec of the ActiveDocs'

      let(:body) { {'basePath' => 'http://pandora-box.example.com', 'apis' => [{'operations' => []}]}.to_json }
    end
  end

  json(:resource) do
    let(:root) { 'api_doc' }
    it do
      should have_properties('id', 'system_name', 'name', 'description', 'published', 'body').from(resource)
      should have_properties('created_at', 'updated_at')
    end
  end

  json(:collection) do
    let(:root) { 'api_docs' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    it('has root') { should have_tag('api_doc') }

    context "root" do
      subject { xml.root }

      it { should have_tag('id') }
      it { should have_tag('body') }
      it { should have_tag('description') }
      it { should have_tag('created_at') }
      it { should have_tag('updated_at') }
    end

  end
end

__END__
admin_api_active_doc PUT    /admin/api/active_docs/:id(.:format) admin/api/api_docs_services#update {:format=>"xml"}
