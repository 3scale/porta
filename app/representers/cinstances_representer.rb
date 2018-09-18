module CinstancesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :applications

  items extend: CinstanceRepresenter
end
