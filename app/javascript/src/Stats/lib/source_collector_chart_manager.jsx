import {StatsChartManager} from 'Stats/lib/chart_manager'

export class StatsSourceCollectorChartManager extends StatsChartManager {
  constructor ({statsState, metricsSelector, sources, chart, widgets = []}) {
    super({statsState, metricsSelector, chart, widgets})
    this.sourceCollector = sources
  }

  get sources () {
    return this._collectSources()
  }

  _collectSources () {
    return this.sourceCollector.getSources(this._options())
  }
}
