module MetricHelper
  def metric_name(metric)
    if metric
      h(metric.friendly_name)
    else
      content_tag(:span, 'missing', :class => 'missing')
    end
  end
end
