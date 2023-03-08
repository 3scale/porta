# frozen_string_literal: true

require 'rails_helper'

resource 'CMS::Layout' do
  let(:resource) { FactoryBot.create(:cms_layout, body: 'body', draft: 'draft', liquid_enabled: true) }

  describe 'representer' do
    let(:root) { 'layout' }

    context 'when requesting all attributes' do
      let(:expected_attributes) do
        %w[id created_at updated_at title system_name liquid_enabled draft published]
      end

      json(:resource) do
        it { should have_properties(expected_attributes).from(resource) }
      end

      xml(:resource) do
        it { should have_tags(expected_attributes).from(resource) }
      end
    end

    context 'when requesting the shorten version' do
      let(:expected_attributes) { %w[id created_at updated_at title system_name liquid_enabled] }
      let(:serialized) { representer.public_send(serialization_format, short: true) }

      json(:resource) do
        it { should have_properties(expected_attributes).from(resource) }
      end

      xml(:resource) do
        it { should have_tags(expected_attributes).from(resource) }
      end
    end
  end
end
