module CMS::FilesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :files

  items extend: CMS::FileRepresenter
end
