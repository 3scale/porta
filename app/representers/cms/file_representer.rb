module CMS::FileRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :created_at
  property :updated_at
  property :title
  property :path
  property :url
  property :section_id
  property :tag_list

  link :section do
    admin_api_cms_section_path section
  end
end
