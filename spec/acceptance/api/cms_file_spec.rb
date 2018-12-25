require 'rails_helper'

resource 'CMS::File' do

  include ActionDispatch::TestProcess # to upload fixture files.

  let(:resource) { FactoryBot.create(:cms_file, provider: provider, section: provider.sections.root) }

  api 'cms file' do

    get '/admin/api/cms/files.:format', action: :index do
      let(:collection) { provider.files }
    end

    get '/admin/api/cms/files/:id.:format', action: :show

    #post '/admin/api/cms/files.:format', action: :create do
    #  parameter :section_id, 'Section where this file belongs'
    #  parameter :attachment, 'The Attachment'
    #  parameter :path, 'The path'

    #  let(:path) { "/magic.foo" }
    #  let(:section_id) { resource.section_id }
    #  let(:attachment) { fixture_file_upload('/wide.jpg',' image/jpeg') }
    #end

    #put '/admin/api/cms/files/:id.:format', action: :update do
    #  parameter :title, 'File title'
    #  let(:title) { 'Mushrooms' }
    #end

    delete '/admin/api/cms/files/:id.:format', action: :destroy
  end

  json(:resource) do
    let(:root) { 'file' }
    it { should have_properties('id', 'path', 'title', 'created_at', 'updated_at').from(resource) }
  end

  json(:collection) do
    let(:root) { 'files' }
  end
end

__END__

admin_api_cms_files     GET      /admin/api/cms/files(.:format)          admin/api/cms/files#index {:format=>"xml"}
                        POST     /admin/api/cms/files(.:format)          admin/api/cms/files#create {:format=>"xml"}
 new_admin_api_cms_file GET      /admin/api/cms/files/new(.:format)      admin/api/cms/files#new {:format=>"xml"}
edit_admin_api_cms_file GET      /admin/api/cms/files/:id/edit(.:format) admin/api/cms/files#edit {:format=>"xml"}
     admin_api_cms_file GET      /admin/api/cms/files/:id(.:format)      admin/api/cms/files#show {:format=>"xml"}
                        PUT      /admin/api/cms/files/:id(.:format)      admin/api/cms/files#update {:format=>"xml"}
                        DELETE   /admin/api/cms/files/:id(.:format)      admin/api/cms/files#destroy {:format=>"xml"}
