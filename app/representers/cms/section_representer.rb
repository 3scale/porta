module CMS::SectionRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :created_at
  property :updated_at
  property :partial_path
  property :public
  property :title
  property :parent_id
  property :system_name
end
