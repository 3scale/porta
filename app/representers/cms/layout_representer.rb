# frozen_string_literal: true

module CMS::LayoutRepresenter
  include ThreeScale::JSONRepresenter

  property :id
  property :type, getter: ->(*) { CMS::TypeMap.cms_type(self.class) }
  property :created_at
  property :updated_at
  property :title
  property :system_name
  property :liquid_enabled

  with_options(if: ->(options) { !options.dig(:user_options, :short) }) do
    property :draft, render_nil: true
    property :published, render_nil: true
  end
end
