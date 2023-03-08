# frozen_string_literal: true

require 'rails_helper'

resource 'CMS::Section' do
  let(:resource) { FactoryBot.create(:cms_section, provider: provider, parent: provider.sections.root) }

  api 'cms section' do
    get '/admin/api/cms/sections.:format', action: :index do
      let(:collection) { provider.sections.order(:id) }
      let(:serialized) { representer.public_send(serialization_format, short: true) }
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

  describe 'representer' do
    let(:expected_attributes) do
      %w[id created_at updated_at title system_name public parent_id partial_path]
    end

    context 'when the resource is a new record' do
      let(:resource) { FactoryBot.build(:cms_section, provider: provider, parent: provider.sections.root) }
      let(:root) { 'section' }
      let(:expected_attributes) { %w[title system_name public parent_id partial_path] }

      json(:resource) do
        it { should have_properties(expected_attributes).from(resource) }
      end

      xml(:resource) do
        it { should have_tags(expected_attributes).from(resource) }
      end
    end

    context 'when requesting a single resource' do
      let(:root) { 'section' }

      json(:resource) do
        it { should have_properties(expected_attributes).from(resource) }
      end

      xml(:resource) do
        it { should have_tags(expected_attributes).from(resource) }
      end
    end

    context 'when requesting a collection' do
      let(:root) { 'sections' }

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
   admin_api_cms_sections  GET      /admin/api/cms/sections(.:format)          admin/api/cms/sections#index {:format=>'xml'}
                           POST     /admin/api/cms/sections(.:format)          admin/api/cms/sections#create {:format=>'xml'}
 new_admin_api_cms_section GET      /admin/api/cms/sections/new(.:format)      admin/api/cms/sections#new {:format=>'xml'}
edit_admin_api_cms_section GET      /admin/api/cms/sections/:id/edit(.:format) admin/api/cms/sections#edit {:format=>'xml'}
     admin_api_cms_section GET      /admin/api/cms/sections/:id(.:format)      admin/api/cms/sections#show {:format=>'xml'}
                           PUT      /admin/api/cms/sections/:id(.:format)      admin/api/cms/sections#update {:format=>'xml'}
                           DELETE   /admin/api/cms/sections/:id(.:format)      admin/api/cms/sections#destroy {:format=>'xml'}
