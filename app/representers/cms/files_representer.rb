module CMS::FilesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :collection

  items extend: CMS::FileRepresenter
end
