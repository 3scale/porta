export class StatsMetric {
  constructor (metric = {}) {
    this._buildMetric(metric)
  }

  _buildMetric (metric) {
    this.id = metric.id
    this.name = metric.friendly_name
    this.serviceId = metric.service_id
    this.systemName = metric.system_name
    this.isMethod = metric.parent_id != null
  }
}
