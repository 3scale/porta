# frozen_string_literal: true

module CMS::PortletRepresenter
  include ThreeScale::JSONRepresenter

  property :id
  property :type, getter: ->(*) { self.class.data_tag }
  property :title
  property :portlet_type
  property :name

  with_options(if: ->(options) { !options[:short] }) do
    property :draft, render_nil: true
    property :published, render_nil: true
  end

  property :liquid_enabled
  property :created_at
  property :updated_at
end
