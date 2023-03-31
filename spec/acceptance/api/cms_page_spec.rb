# frozen_string_literal: true

require 'rails_helper'

resource 'CMS::Page' do
  let(:resource) do
    FactoryBot.create(
      :cms_page,
      system_name: 'some-partial',
      layout_id: 1,
      handler: 'markdown',
      body: 'body',
      draft: 'draft',
      liquid_enabled: true
    )
    end

  describe 'representer' do
    context 'when requesting all attributes' do
      let(:expected_attributes) do
        %w[
          id
          type
          created_at
          updated_at
          title
          system_name
          layout_id
          section_id
          path
          content_type
          liquid_enabled
          handler
          hidden
          draft
          published
        ]
      end

      json(:resource, skip_resource_save: true, skip_root_check: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end
    end

    context 'when requesting the shorten version' do
      let(:expected_attributes) do
        %w[
          id
          type
          created_at
          updated_at
          title
          system_name
          layout_id
          section_id
          path
          content_type
          liquid_enabled
          handler
          hidden
        ]
      end

      let(:serialized) { representer.public_send(serialization_format, short: true) }

      json(:resource, skip_resource_save: true, skip_root_check: true) do
        it 'should have the correct attributes' do
          expect(subject.keys).to eq(expected_attributes)
        end
      end
    end
  end
end
