module CMS::PageRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  with_options(if: lambda {|options| options[:short] == false }) do |p|
    p.property :draft, render_nil: true
    p.property :published, render_nil: true
  end

  property :system_name
  property :liquid_enabled

  with_options(if: ->(*) { is_a?(CMS::Page) }) do |p|
    # this needs a getter
    p.property :path, if: ->(*) { respond_to?(:path) }
    p.property :title
    p.property :hidden
    p.property :layout
    p.property :content_type
    p.property :handler
  end

  property :created_at
  property :updated_at

  def hidden
    hidden?
  end
end
