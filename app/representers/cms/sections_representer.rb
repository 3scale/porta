module CMS::SectionsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :collection

  items extend: CMS::SectionRepresenter
end
