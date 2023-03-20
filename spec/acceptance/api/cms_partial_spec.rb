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
    ).extend(CMS::PartialRepresenter)
  end

  describe 'representer' do
    context 'when requesting all attributes' do
      let(:expected_attributes) { %w[id type created_at updated_at system_name draft published] }

      json(:resource, skip_root_check: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end
    end

    context 'when requesting the shorten version' do
      let(:expected_attributes) { %w[id type created_at updated_at system_name] }
      let(:serialized) { representer.public_send(serialization_format, short: true) }

      json(:resource, skip_root_check: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end
    end
  end
end
