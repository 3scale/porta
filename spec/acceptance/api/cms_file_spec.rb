# frozen_string_literal: true

require 'rails_helper'

resource 'CMS::File' do
  include ActionDispatch::TestProcess # to upload fixture files.

  let(:resource) { FactoryBot.create(:cms_file, provider: provider, section: provider.sections.root) }

  api 'cms file', format: [:json] do
    get '/admin/api/cms/files', action: :index do
      let(:collection) { provider.files }
      let(:serialized) { representer.public_send(serialization_format, short: true) }
    end

    get '/admin/api/cms/files/:id', action: :show

    post '/admin/api/cms/files', action: :create do
      parameter :path, 'The path'
      parameter :section_id, 'Section where this file belongs'
      parameter :attachment, 'The Attachment'

      let(:section_id) { resource.section_id }
      let(:attachment) { fixture_file_upload(Rails.root.join('test', 'fixtures', 'wide.jpg'),' image/jpeg') }
    end

    put '/admin/api/cms/files/:id', action: :update do
      parameter :downloadable, 'Checked sets the content-disposition to attachment'

      let(:downloadable) { true }
    end

    delete '/admin/api/cms/files/:id', action: :destroy
  end

  describe 'representer' do
    let(:expected_attributes) do
      %w[id created_at updated_at section_id path downloadable url title content_type]
    end

    context 'when the resource is a new record' do
      let(:resource) { FactoryBot.build(:cms_file, provider: provider, section: provider.sections.root) }
      let(:expected_attributes) { %w[section_id path downloadable url title content_type] }

      json(:resource, skip_resource_save: true, skip_root_check: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end
    end

    context 'when requesting a single resource' do
      json(:resource, skip_root_check: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end
    end

    context 'when requesting a collection' do
      let(:root) { 'collection' }

      json(:collection) do
        it 'returns a collection of cms files' do
          expect(subject).to be_a(Array)
          expect(subject.first.keys).to eq(expected_attributes)
        end
      end
    end
  end
end

__END__

admin_api_cms_files     GET      /admin/api/cms/files(.:format)          admin/api/cms/files#index {:format=>"json"}
                        POST     /admin/api/cms/files(.:format)          admin/api/cms/files#create {:format=>"json"}
 new_admin_api_cms_file GET      /admin/api/cms/files/new(.:format)      admin/api/cms/files#new {:format=>"json"}
edit_admin_api_cms_file GET      /admin/api/cms/files/:id/edit(.:format) admin/api/cms/files#edit {:format=>"json"}
     admin_api_cms_file GET      /admin/api/cms/files/:id(.:format)      admin/api/cms/files#show {:format=>"json"}
                        PUT      /admin/api/cms/files/:id(.:format)      admin/api/cms/files#update {:format=>"json"}
                        DELETE   /admin/api/cms/files/:id(.:format)      admin/api/cms/files#destroy {:format=>"json"}
