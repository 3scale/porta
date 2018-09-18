module ReportsHelper
  # Format report value with unit
  def report_value(report)
    report.metric ? pluralize(report.value, report.metric.unit) : report.value
  end

  def report_metric(report)
    report.metric.try!(:friendly_name) || content_tag(:span, 'deleted', :class => 'deleted')
  end
end
