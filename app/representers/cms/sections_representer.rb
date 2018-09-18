module CMS::SectionsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :sections

  items extend: CMS::SectionRepresenter
end
