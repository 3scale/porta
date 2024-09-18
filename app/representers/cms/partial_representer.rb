# frozen_string_literal: true

module CMS::PartialRepresenter
  include ThreeScale::JSONRepresenter

  property :id
  property :type, getter: ->(*) { CMS::TypeMap.cms_type(self.class) }
  property :created_at
  property :updated_at
  property :system_name

  with_options(if: ->(options) { !options[:user_options]&.dig(:short) }) do
    property :draft, render_nil: true
    property :published, render_nil: true
  end
end
