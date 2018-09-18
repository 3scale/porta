module ReferrerFiltersRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :referrer_filters

  items extend: ReferrerFilterRepresenter
end
