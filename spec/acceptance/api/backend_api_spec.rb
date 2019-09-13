# frozen_string_literal: true

require 'rails_helper'

resource 'BackendApi' do
  let(:resource) { FactoryBot.build(:backend_api) }
  let(:expected_properties) { %w[id name system_name description private_endpoint account_id created_at updated_at] }

  json(:resource) do
    let(:root) { 'backend_api' }

    it { subject.should have_properties(expected_properties).from(resource) }
    it { should have_links('metrics') }
  end

  json(:collection) do
    let(:root) { 'backend_apis' }
    context do
      let(:collection) { [resource, FactoryBot.create(:backend_api)] }
      it 'contains the backend apis data by its representer' do
        assert_equal collection.length, subject.length
        subject.each do |subject_backend_api|
          subject_backend_api.should include('backend_api')
          backend_api = collection.find { |backend_api| backend_api.id == subject_backend_api.fetch('backend_api').fetch('id') }
          subject_backend_api.fetch('backend_api').should have_properties(expected_properties).from(backend_api)
        end
      end
    end
  end
end
