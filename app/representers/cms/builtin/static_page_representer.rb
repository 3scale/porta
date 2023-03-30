module CMS::Builtin::StaticPageRepresenter
  include ThreeScale::JSONRepresenter

  property :id
  property :type, getter: ->(*) { CMS::TypeMap.cms_type(self.class) }
  property :system_name
  property :layout, render_nil: true
  property :created_at
  property :updated_at
end
