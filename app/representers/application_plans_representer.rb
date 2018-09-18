module ApplicationPlansRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :plans

  items extend: ApplicationPlanRepresenter
end
