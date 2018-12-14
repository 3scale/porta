# frozen_string_literal: true

module MetricsWithMethodsRepresenter
  include ThreeScale::JSONRepresenter
  include FieldsRepresenter
  include ExtraFieldsRepresenter

  collection :metrics, decorator: MetricRepresenter
  collection :methods, decorator: MetricRepresenter
end
