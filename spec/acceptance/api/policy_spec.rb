# frozen_string_literal: true

require 'rails_helper'

resource 'Policy' do
  let(:resource) { FactoryBot.create(:policy) }

  json(:resource) do
    let(:root) { 'policy' }

    it { subject.should have_properties(%w[id name version schema created_at updated_at]).from(resource) }
  end
end
