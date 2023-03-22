# frozen_string_literal: true

require 'rails_helper'

resource "CMS::Partial" do
  let(:resource) do
    FactoryBot.create(
      :cms_partial,
      body: 'body',
      draft: 'draft',
      system_name: 'some-partial',
      liquid_enabled: false,
      handler: 'markdown'
    )
  end

  describe 'representer' do
    let(:root) { 'partial' }

    context 'when requesting all attributes' do
      let(:expected_attributes) { %w[id created_at updated_at system_name draft published] }

      json(:resource) do
        it { should have_properties(expected_attributes).from(resource) }
      end

      xml(:resource) do
        it { should have_tags(expected_attributes).from(resource) }
      end
    end

    context 'when requesting the shorten version' do
      let(:expected_attributes) { %w[id created_at updated_at system_name] }
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
