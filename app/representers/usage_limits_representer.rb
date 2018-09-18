module UsageLimitsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :limits

  items extend: UsageLimitRepresenter
end
