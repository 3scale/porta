module MetricsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :metrics

  items extend: MetricRepresenter
end
