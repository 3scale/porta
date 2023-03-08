# frozen_string_literal: true

module CMS::PartialRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource ->(*) { self.class.data_tag }

  property :id
  property :created_at
  property :updated_at
  property :system_name

  with_options(if: ->(options) { !options[:short] }) do
    property :draft, render_nil: true
    property :published, render_nil: true
  end
end
