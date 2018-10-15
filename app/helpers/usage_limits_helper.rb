module UsageLimitsHelper

  def display_usage_limit(usage_limit)
    h "#{usage_limit.value} #{usage_limit.metric.unit} / #{usage_limit.period}"
  end

  def display_metric_name(metric)
    name = metric.friendly_name
    content_tag(:span, name, title: name)
  end
end
