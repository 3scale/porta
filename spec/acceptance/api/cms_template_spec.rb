require 'spec_helper'

resource "CMS::Template" do

  let(:resource) { double.as_null_object }
  let(:partial) { Factory.build(:cms_partial, provider: provider) }
  let(:layout) { Factory.build(:cms_layout, provider: provider) }
  let(:page) { Factory.build(:cms_page, provider: provider) }
  let(:section) { Factory(:cms_section, provider: provider, parent: provider.sections.root) }

  let(:collection) { [partial, layout, page] }

  shared_examples "cms resource" do
    post '/admin/api/cms/templates.:format', action: :create do
      let(:resource) { CMS::Template.last }
      parameter :type, 'Type of the CMS Template'
    end
    get '/admin/api/cms/templates/:id.:format', action: :show
    put '/admin/api/cms/templates/:id.:format', action: :update
    put '/admin/api/cms/templates/:id.:format', action: :publish do
      before { resource.should be_dirty }
      after { resource.should_not be_dirty }
    end
    delete '/admin/api/cms/templates/:id.:format', action: :destroy do
      after { expect{ resource.reload }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  api 'cms template' do
    get '/admin/api/cms/templates.:format', action: :index do
      before { collection.each(&:save!).sort_by!(&:id) }
      let(:serialized) { representer.send(serialization_format, short: true) }
    end

    context do
      parameter :draft, 'Text content of the template (you have to publish the template)'
      parameter :handler, 'text will be processed by the handler before rendering'

      context "layout", resource_name: 'CMS::Layout' do
        let(:resource) { layout }
        parameter :system_name, 'System name'
        parameter :title, 'Title of the template'

        let(:type) { 'layout' }
        let(:system_name) { 'layout-system-name' }
        let(:title) { 'Awesome Layout' }

        include_examples "cms resource"
      end

      context "partial", resource_name: 'CMS::Partial' do
        let(:resource) { partial }
        parameter :system_name, 'System name'

        let(:type) { 'partial' }
        let(:system_name) { 'partial-system-name' }

        include_examples "cms resource"
      end

      context "page", resource_name: 'CMS::Page' do
        let(:resource) { page }

        parameter :title, 'Title of the template'
        parameter :path, 'URI of the page'
        parameter :section_id, 'ID of a section (valid only for pages)'
        parameter :layout_name, 'system name of a layout'
        parameter :layout_id, 'ID of a layout'
        parameter :liquid_enabled, 'liquid processing of the template content on/off'

        let(:type) { 'page' }

        let(:path) { '/some-page' }
        let(:section_id) { section.id }
        let(:layout_id) { layout.id }
        let(:liquid_enabled) { true }
        let(:draft) { 'some content' }
        let(:title) { 'Awesome Page' }

        include_examples "cms resource"
      end
    end
  end

  json(:collection) do
    let(:root) { 'templates' }
    it { should be_an(Array) }

    context do
      let(:page) { Factory(:cms_page, path: '/some-path') }
      let(:layout) { Factory(:cms_layout, title: 'title', system_name: 'layout') }
      let(:partial) { Factory(:cms_partial, liquid_enabled: true) }
      let(:collection) { [page, layout, partial] }

      it "should be wrapped by relevant representers" do
        s_page, s_layout, s_partial = subject

        s_page.should == JSON.parse(page.to_json)
        s_layout.should == JSON.parse(layout.to_json)
        s_partial.should == JSON.parse(partial.to_json)
      end
    end
  end
end

__END__
 publish_admin_api_cms_template PUT    /admin/api/cms/templates/:id/publish(.:format) admin/api/cms/templates#publish {:format=>"xml"}
        admin_api_cms_templates GET    /admin/api/cms/templates(.:format)             admin/api/cms/templates#index {:format=>"xml"}
                                POST   /admin/api/cms/templates(.:format)             admin/api/cms/templates#create {:format=>"xml"}
         admin_api_cms_template GET    /admin/api/cms/templates/:id(.:format)         admin/api/cms/templates#show {:format=>"xml"}
                                PUT    /admin/api/cms/templates/:id(.:format)         admin/api/cms/templates#update {:format=>"xml"}
