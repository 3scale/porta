module ServicePlansRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :plans

  items extend: ServicePlanRepresenter
end
