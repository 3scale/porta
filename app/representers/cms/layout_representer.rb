module CMS::LayoutRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :title
  property :system_name
  property :content_type
  property :handler, render_nil: true

  with_options(if: lambda {|options| options[:short] == false }) do |p|
    p.property :published, render_nil: true
    p.property :draft, render_nil: true
  end

  property :created_at
  property :updated_at
end
