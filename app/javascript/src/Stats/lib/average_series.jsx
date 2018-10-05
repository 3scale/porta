import {StatsSeries} from './series'

export class StatsAverageSeries extends StatsSeries {
  _seriesOptions (responses) {
    let seriesData = responses.map(response => this._parseResponseData(response))
    return {
      columns: [
        ...seriesData // flattens array
      ],
      unload: true,
      _totalValues: responses.map((response) => response.total).reduce((previous, current) => previous + current, 0)
    }
  }
}
