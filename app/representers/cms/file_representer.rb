# frozen_string_literal: true

module CMS
  module FileRepresenter
    include ThreeScale::JSONRepresenter

    wraps_resource ->(*) { self.class.data_tag }

    with_options(unless: :new_record?) do
      property :id
      property :created_at
      property :updated_at
    end

    property :section_id
    property :path
    property :downloadable, getter: ->(*) { downloadable? }
    property :url
    property :title
    property :content_type, getter: ->(*) { attachment.content_type }
  end
end
