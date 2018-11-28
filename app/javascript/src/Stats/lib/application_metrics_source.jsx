import {StatsMetricsSource} from './metrics_source'

export class StatsApplicationMetricsSource extends StatsMetricsSource {
  get url () {
    return `/stats/applications/${this.id}/usage.json`
  }
}
