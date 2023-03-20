# frozen_string_literal: true

module CMS
  module SectionRepresenter
    include ThreeScale::JSONRepresenter

    with_options(unless: :new_record?) do
      property :id
      property :created_at
      property :updated_at
    end

    property :title, render_nil: true
    property :system_name
    property :public
    property :parent_id, render_nil: true
    property :partial_path, render_nil: true
  end
end
