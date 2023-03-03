# frozen_string_literal: true

module CMS
  module SectionRepresenter
    include ThreeScale::JSONRepresenter

    wraps_resource -> (*) { self.class.data_tag }

    with_options(unless: :new_record?) do
      property :id
      property :created_at
      property :updated_at
    end

    property :title
    property :system_name
    property :public
    property :parent_id
    property :partial_path
  end
end
