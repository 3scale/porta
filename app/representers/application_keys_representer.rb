module ApplicationKeysRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :keys

  items extend: ApplicationKeyRepresenter
end
