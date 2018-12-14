# frozen_string_literal: true

module MetricsWithMethodsRepresenter
  include ThreeScale::JSONRepresenter
  include FieldsRepresenter
  include ExtraFieldsRepresenter

  # collection :metrics, decorator: MetricsRepresenter, wrap: false
  # property :metrics, decorator: MetricsRepresenter, wrap: false
  # collection :metrics do
  #   property :id
  # end
  # property :methods, decorator: MethodsRepresenter # , wrap: false

  collection :metrics, wrap: false do
    nested :metric do
      property :id, render_nil: true
      property :system_name, render_nil: true
      property :description, render_nil: true
      property :unit, render_nil: true
      property :created_at, render_nil: true
      property :updated_at, render_nil: true
      property :service_id, render_nil: true
      property :friendly_name, render_nil: true
      property :parent_id, render_nil: true
      property :tenant_id, render_nil: true
      property :visible, render_nil: true
    end
  end

  collection :methods, wrap: false do
    nested :metric do
      property :id, render_nil: true
      property :system_name, render_nil: true
      property :description, render_nil: true
      property :unit, render_nil: true
      property :created_at, render_nil: true
      property :updated_at, render_nil: true
      property :service_id, render_nil: true
      property :friendly_name, render_nil: true
      property :parent_id, render_nil: true
      property :tenant_id, render_nil: true
      property :visible, render_nil: true
    end
  end

  # collection :metrics, decorator: MetricsRepresenter, wrap: false # , inherit: true
  # property :metrics, decorator: MetricsRepresenter, wrap: false # , inherit: true
end
