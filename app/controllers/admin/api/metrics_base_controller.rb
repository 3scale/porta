class Admin::Api::MetricsBaseController < Admin::Api::ServiceBaseController
  include MetricParams

  protected

  def metric
    raise NotImplementedError.new "#{self.class.name} should implemented metric method"
  end

  def metrics
    @metrics ||= service.metrics
  end
end
