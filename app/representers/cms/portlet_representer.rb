module CMS::PortletRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :title
  property :portlet_type
  property :name

  with_options(if: ->(options) { options[:short] == false }) do |p|
    p.property :draft
    p.property :published
  end

  property :liquid_enabled
  property :created_at
  property :updated_at

end
