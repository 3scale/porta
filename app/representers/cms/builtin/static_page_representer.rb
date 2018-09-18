module CMS::Builtin::StaticPageRepresenter

  include ThreeScale::JSONRepresenter

  wraps_resource(:builtin_page)

  property :id
  property :system_name
  property :layout, render_nil: true
  property :created_at
  property :updated_at
end
