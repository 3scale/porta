# frozen_string_literal: true

require 'rails_helper'

resource 'CMS::File' do
  include ActionDispatch::TestProcess # to upload fixture files.

  let(:resource) { FactoryBot.create(:cms_file, provider: provider, section: provider.sections.root) }

  api 'cms file' do
    get '/admin/api/cms/files.:format', action: :index do
      let(:collection) { provider.files }
      let(:serialized) { representer.public_send(serialization_format, short: true) }
    end

    get '/admin/api/cms/files/:id.:format', action: :show

    post '/admin/api/cms/files.:format', action: :create do
      parameter :path, 'The path'
      parameter :section_id, 'Section where this file belongs'
      parameter :attachment, 'The Attachment'

      let(:section_id) { resource.section_id }
      let(:attachment) { fixture_file_upload('/wide.jpg',' image/jpeg') }
    end

    put '/admin/api/cms/files/:id.:format', action: :update do
      parameter :downloadable, 'Checked sets the content-disposition to attachment'

      let(:downloadable) { true }
    end

    delete '/admin/api/cms/files/:id.:format', action: :destroy
  end

  describe 'representer' do
    let(:expected_attributes) do
      %w[id created_at updated_at section_id path downloadable url title content_type]
    end

    context 'when the resource is a new record' do
      let(:resource) { FactoryBot.build(:cms_file, provider: provider, section: provider.sections.root) }
      let(:root) { 'file' }
      let(:expected_attributes) { %w[section_id path downloadable url title content_type] }

      json(:resource, skip_resource_save: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end

      xml(:resource) do
        it 'should have the correct attributes' do
          expect(subject.root.elements.map(&:name)).to eq(expected_attributes)
        end
      end
    end

    context 'when requesting a single resource' do
      let(:root) { 'file' }

      json(:resource) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end

      xml(:resource) do
        it 'should have the correct attributes' do
          expect(subject.root.elements.map(&:name)).to eq(expected_attributes)
        end
      end
    end

    context 'when requesting a collection' do
      let(:root) { 'files' }

      json(:collection)

      xml(:collection) do
        it 'should have root' do
          expect(xml).to have_tag(root)
        end
      end
    end
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
