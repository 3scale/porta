import {StatsChartManager} from './chart_manager'

export class StatsSourceCollectorChartManager extends StatsChartManager {
  constructor ({statsState, sources, chart, widgets = []}) {
    super({statsState, chart, widgets})
    this.sourceCollector = sources
  }

  get sources () {
    return this._collectSources()
  }

  _collectSources () {
    return this.sourceCollector.getSources(this._options())
  }
}
