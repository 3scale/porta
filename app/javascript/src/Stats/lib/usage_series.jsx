import {StatsSeries} from './series'

export class StatsUsageSeries extends StatsSeries {
  _customOptions (responses) {
    return {
      _methodsTableData: responses.map(response => {
        return {
          period: response.period,
          name: response.metric.name,
          systemName: response.metric.system_name,
          total: response.total,
          unit: response.metric.unit
        }
      })
    }
  }
}
