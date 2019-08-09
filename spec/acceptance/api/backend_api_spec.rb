# frozen_string_literal: true

require 'rails_helper'

resource 'BackendApi' do
  let(:resource) { FactoryBot.create(:backend_api) }
  let(:expected_properties) { %w[id name system_name description private_endpoint account_id created_at updated_at] }

  json(:resource) do
    let(:root) { 'backend_api' }

    it { subject.should have_properties(expected_properties).from(resource) }
  end

  json(:collection) do
    let(:root) { 'backend_apis' }
    context do
      let(:collection) { [resource, resource] }
      it 'contains the backend apis data by its representer' do
        subject.each do |subject_backend_api|
          subject_backend_api.should include('backend_api')
          subject_backend_api.fetch('backend_api').should have_properties(expected_properties).from(resource)
        end
      end
    end
  end
end
