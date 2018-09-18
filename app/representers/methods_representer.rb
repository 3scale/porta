module MethodsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :methods

  items extend: MethodRepresenter
end
