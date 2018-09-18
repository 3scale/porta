module CMS::TemplateRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :created_at
  property :updated_at
end
