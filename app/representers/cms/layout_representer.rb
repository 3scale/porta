module CMS::LayoutRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :created_at
  property :updated_at
  property :title
  property :system_name
  property :liquid_enabled

  with_options(if: ->(options) { !options[:short] }) do |p|
    p.property :draft, render_nil: true
    p.property :published, render_nil: true
  end
end
