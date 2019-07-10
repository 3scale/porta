class DashboardWidgetPresenter
  include ::Draper::ViewHelpers

  attr_reader :name, :params, :value, :previous_value, :percentual_change, :has_history, :current

  # TODO: clearly this should be just one attribute, and controllers should inject own structure
  attr_reader :chart, :items

  def initialize(name, params = {})
    @name = name
    @params = params.freeze
    @data = nil
    @value = spinner
    @previous_value = nil
    @percentual_change = spinner
    @has_history = false
  end

  def render
    content = h.render(partial: template_name, locals: locals)
    content << h.render(partial: ajax_load, locals: locals) unless loaded? # trigger ajax refresh when not toggled
    content
  end

  def render_chart
    return unless chart

    h.render(partial: load_chart, locals: locals)
  end

  def url(params = self.params)
    h.polymorphic_url([:provider, :admin, :dashboard, name], params)
  end

  def path
    url(params.merge(routing_type: :path))
  end

  def current
    @current.try(:[], :formatted_value)
  end

  def id
    "dashboard-widget-#{params.to_a.join('-')}#{name}"
  end

  def template_name
    "provider/admin/dashboards/widgets/#{name}"
  end

  def ajax_load
    'provider/admin/dashboards/ajax_load'.freeze
  end

  def load_chart
    'provider/admin/dashboards/widgets/chart'.freeze
  end

  # @param data [Hash]
  def data=(data)
    @loaded = true
    @data = data
    @value = data.delete(:value)
    @previous_value = data.delete(:previous_value)
    @percentual_change = data.delete(:percentual_change)
    @chart = data.delete(:chart)
    @items = data.delete(:items)
    @current = data.delete(:current) || 0
    @has_history = data.delete(:has_history)
  end

  def loaded?
    !@loaded.nil?
  end

  def spinner
    h.content_tag(:i, ''.freeze, class: 'fa fa-spinner fa-spin fa-3x DashboardWidget-spinner'.freeze)
  end

  def locals
    { widget: self }
  end
end
