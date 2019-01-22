# frozen_string_literal: true

require 'rails_helper'

resource 'AccessToken' do
  let(:resource) { FactoryBot.build(:access_token) }
  let(:expected_properties) { %w[id name scopes permission value] }

  json(:resource) do
    let(:root) { 'access_token' }

    it { subject.should have_properties(expected_properties).from(resource) }
  end

  json(:collection) do
    let(:root) { 'access_tokens' }
    context do
      let(:collection) { [resource, resource] }
      it 'contains the access token data by its representer' do
        subject.each do |subject_access_token|
          subject_access_token.should include('access_token')
          subject_access_token.fetch('access_token').should have_properties(expected_properties).from(resource)
        end
      end
    end
  end
end
