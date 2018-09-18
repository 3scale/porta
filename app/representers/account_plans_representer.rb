module AccountPlansRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :plans

  items extend: AccountPlanRepresenter
end
