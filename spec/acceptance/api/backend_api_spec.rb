# frozen_string_literal: true

require 'rails_helper'

resource 'BackendApi' do
  let(:resource) { FactoryBot.create(:backend_api) }

  json(:resource) do
    let(:root) { 'backend_api' }

    it { subject.should have_properties(%w[id name system_name description private_endpoint account_id created_at updated_at]).from(resource) }
  end
end
