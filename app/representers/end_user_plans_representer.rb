module EndUserPlansRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :end_user_plans

  items extend: EndUserPlanRepresenter
end
