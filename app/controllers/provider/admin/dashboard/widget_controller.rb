class Provider::Admin::Dashboard::WidgetController < Provider::Admin::BaseController
  helper_method :widget, :current_range, :previous_range
  before_action :load_widget

  respond_to :js, :html, :json

  def show
    respond_with widget
  end

  protected

  include DashboardTimeRange

  def timeline_data(current_data, previous_data)
    current_data_keys = current_data.keys
    incomplete_slice  = current_data.slice(current_data_keys.pop)
    current_slice     = current_data.slice(*current_data_keys)
    current_sum       = get_sum_from_values(current_slice.values)
    previous_sum      = get_sum_from_values(previous_data.values)
    percentual_change = ((current_sum.to_f - previous_sum.to_f) / previous_sum.to_f) * 100

    {
      chart: {
        values:   current_data,
        complete:   current_slice,
        incomplete: incomplete_slice,
        previous:   previous_data
      },
      value:             current_sum,
      current:           incomplete_slice.values.sum,
      previous_value:    previous_sum,
      percentual_change: percentual_change,
      has_history:       previous_sum > 0
    }
  end

  def load_widget
    widget.data = widget_data.merge(current_range: current_range, previous_range: previous_range)
  end

  def widget_data
    {}
  end

  # @return DashboardWidgetPresenter
  def widget
    @widget ||= DashboardWidgetPresenter.new(widget_name, params.except(:action, :controller, :format))
  end

  def widget_name
    self.class.name.sub('Provider::Admin::Dashboard::', '').underscore.sub(/_controller$/, '').tr('/', '_')
  end

  private

  def get_sum_from_values(values)
    values.sum{ |value| value[:value] }
  end
end
