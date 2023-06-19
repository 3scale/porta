export const HITS_METRIC = /hits(\.\d+)?/

export class StatsMetric {
  constructor (metric = {}) {
    this._buildMetric(metric)
  }

  _buildMetric (metric) {
    const systemName = metric.system_name
    const parentId = metric.parent_id

    this.id = metric.id
    this.name = metric.friendly_name
    this.serviceId = metric.service_id
    this.systemName = systemName
    this.parentId = parentId
    this.isMethod = parentId != null
    this.isHits = !!systemName.match(HITS_METRIC)
  }
}
