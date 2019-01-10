# frozen_string_literal: true

require 'rails_helper'

resource 'AccessToken' do
  let(:resource) { FactoryBot.build(:access_token) }

  json(:resource) do
    let(:root) { 'access_token' }

    it { subject.should have_properties(%w[id name scopes permission value]).from(resource) }
  end
end
