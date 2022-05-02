# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

describe 'Service API', type: :request, swagger_doc: '/doc/active_docs/swagger.json' do

  let(:resource) { FactoryBot.build(:service,
    account: provider,
    system_name: 'foobar',
    buyer_plan_change_permission: 'request_credit_card',
    notification_settings: {
      web_provider: ['', '50', '100', '300'],
      email_provider: ['', '50', '100', '150'],
      web_buyer: ['', '50', '100', '150'],
      email_buyer: ['', '50', '100', '300']
    }
  )}
  let(:attributes) { %w[id system_name intentions_required buyers_manage_apps buyers_manage_keys referrer_filters_required custom_keys_enabled buyer_key_regenerate_enabled mandatory_app_key buyer_can_select_plan buyer_plan_change_permission] }

  before do
    provider.settings.allow_multiple_services!
  end

  path '/admin/api/services.:format' do
    parameter name: :service_name, in: :path, type: :string

    let(:serializable) { [provider.services.default, resource.reload] }

    get 'reload resource because it has been touched' do
      tags 'Service'
      consumes 'application/json'
      produces 'application/json'
    end
  end

  # path '/admin/api/services/:id.:format' do
  #   before { resource.reload }
    
  #   get 'show service' do
  #     tags 'Service'
  #     consumes 'application/json'
  #     parameter name: :service_name, in: :body, schema: {
  #       type: :object,
  #     }
  #   end
  # end

  path '/admin/api/services.:format' do
    post 'create service' do
      tags 'Service'
      consumes 'application/json'

      parameter name: "Service Name", in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        },
        required: [ 'name' ]
      }
      
      let(:name) { 'Example service' }
      
      response '201', 'service created' do
        
        run_test!
      end
    end
  end

  # path '/admin/api/services/:id.:format' do

  #   put 'update service' do
  #     tags 'Service'
  #     consumes 'application/json'
  #     parameter name: :service_name, in: :body, schema: {
  #       type: :object,
  #     }


  #      response '200', 'blog updated' do
  #       let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/thumbnail.png")) }
  #       run_test!
  #     end

  #   end
  # end
  

  # api 'service' do
  #   parameter :name, 'Service Name'

  #   get "/admin/api/services.:format", action: :index do
  #     # reload resource because it has been touched
  #     let(:serializable) { [provider.services.default, resource.reload] }
  #   end

  #   get "/admin/api/services/:id.:format", action: :show do
  #     before { resource.reload }
  #   end

  #   post "/admin/api/services.:format", action: :create do
  #     parameter :name, 'Service Name'
  #     let(:name) { 'Example service' }
  #   end

  #   put "/admin/api/services/:id.:format", action: :update do
  #     parameter :name, 'Service Name'
  #     let(:name) { 'some name' }
  #   end
  # end

  # xml(:resource) do
  #   before { resource.save! }

  #   let(:root) { 'service' }

  #   it { should have_tag(root) }

  #   context 'service' do
  #     subject(:service) { Hash.from_xml(serialized).fetch(root) }
  #     it { should include(attributes.map do |attr_name|
  #       next if (attr_value = resource.public_send(attr_name)).blank?
  #       [attr_name, attr_value.to_s]
  #     end.compact.to_h)}
  #     it { should include('notification_settings' => resource.notification_settings.stringify_keys.transform_values(&:to_s)) }
  #   end
  # end

  # json(:resource) do
  #   before { resource.save! }

  #   let(:root) { 'service' }

  #   it { should include(attributes.map { |attr_name| [attr_name, resource.public_send(attr_name)] }.to_h.delete_if { |k, v| v.nil? })}
  #   it { should include('notification_settings' => resource.notification_settings.stringify_keys) }
  #   it { should have_links(%w|self service_plans application_plans features metrics|)}
  # end

  # json(:collection) do
  #   let(:root) { 'services' }
  #   it { should be_an(Array) }
  # end
end

__END__

admin_api_services GET    /admin/api/services(.:format)      admin/api/services#index {:format=>"xml"}
                   POST   /admin/api/services(.:format)      admin/api/services#create {:format=>"xml"}
 admin_api_service GET    /admin/api/services/:id(.:format)  admin/api/services#show {:format=>"xml"}
                   PUT    /admin/api/services/:id(.:format)  admin/api/services#update {:format=>"xml"}
                   DELETE /admin/api/services/:id(.:format)  admin/api/services#destroy {:format=>"xml"}
