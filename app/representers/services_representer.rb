module ServicesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :services

  items extend: ServiceRepresenter
end
