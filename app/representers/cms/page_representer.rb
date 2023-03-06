# frozen_string_literal: true

module CMS::PageRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource ->(*) { self.class.data_tag }

  property :id
  property :created_at
  property :updated_at
  property :title
  property :system_name, render_nil: true
  property :layout_id, render_nil: true

  with_options(if: ->(*) { is_a?(CMS::Page) }) do |p|
    p.property :section_id
    p.property :path, if: ->(*) { respond_to?(:path) }
    p.property :content_type
    p.property :liquid_enabled, getter: ->(*) { liquid_enabled? }
    p.property :handler
    p.property :hidden, getter: ->(*) { hidden? }
  end

  with_options(if: ->(options) { !options[:short] }) do
    property :draft, render_nil: true
    property :published, render_nil: true
  end
end
