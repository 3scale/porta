module CMS::PartialRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :system_name

  with_options(if: lambda {|options| options[:short] == false }) do |p|
    p.property :published, render_nil: true
    p.property :draft, render_nil: true
  end

  property :handler
  property :liquid_enabled

  property :created_at
  property :updated_at
end
