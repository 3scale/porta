module AccountPlanRepresenter
  include ThreeScale::JSONRepresenter
  include PlanRepresenter

  wraps_resource
end
