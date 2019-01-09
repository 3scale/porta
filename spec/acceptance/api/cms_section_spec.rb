require 'rails_helper'

resource 'CMS::Section' do

  let(:resource) { FactoryBot.create(:cms_section, provider: provider, parent: provider.sections.root) }

  api 'cms section' do

    get '/admin/api/cms/sections.:format', action: :index do
      let(:collection) { provider.sections.order(:id) }
    end

    get '/admin/api/cms/sections/:id.:format', action: :show

    post '/admin/api/cms/sections.:format', action: :create do
      parameter :parent_id, 'The Parent Section'
      parameter :title, 'Section Title'

      let(:title) { 'slopestyle' }
      let(:parent_id) { resource.parent_id }
    end

    put '/admin/api/cms/sections/:id.:format', action: :update do
      parameter :title, 'Section Title'
      let(:title) { 'Magic Section' }
    end

    delete '/admin/api/cms/sections/:id.:format', action: :destroy
  end

  json(:resource) do
    let(:root) { 'section' }
    it { should have_properties('id', 'parent_id', 'system_name', 'title', 'created_at', 'updated_at').from(resource) }
  end

  json(:collection) do
    let(:root) { 'sections' }
  end
end

__END__
   admin_api_cms_sections  GET      /admin/api/cms/sections(.:format)          admin/api/cms/sections#index {:format=>'xml'}
                           POST     /admin/api/cms/sections(.:format)          admin/api/cms/sections#create {:format=>'xml'}
 new_admin_api_cms_section GET      /admin/api/cms/sections/new(.:format)      admin/api/cms/sections#new {:format=>'xml'}
edit_admin_api_cms_section GET      /admin/api/cms/sections/:id/edit(.:format) admin/api/cms/sections#edit {:format=>'xml'}
     admin_api_cms_section GET      /admin/api/cms/sections/:id(.:format)      admin/api/cms/sections#show {:format=>'xml'}
                           PUT      /admin/api/cms/sections/:id(.:format)      admin/api/cms/sections#update {:format=>'xml'}
                           DELETE   /admin/api/cms/sections/:id(.:format)      admin/api/cms/sections#destroy {:format=>'xml'}
