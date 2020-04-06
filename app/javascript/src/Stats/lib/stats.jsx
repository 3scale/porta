import 'core-js/fn/object/assign' // make Object.assign on IE 11
import {StatsStore} from 'Stats/lib/store'
import {StatsState, PeriodRangeDate} from 'Stats/lib/state'
import {StatsMenu} from 'Stats/lib/menu'
import {StatsMetricsSelector} from 'Stats/lib/metrics_selector'
import {StatsApplicationsSelector} from 'Stats/lib/applications_selector'

export const Stats = function ({ChartManager, Chart, Sources}) {
  const DEFAULT_PERIODS = [
    { number: 24, unit: 'hour' },
    { number: 7, unit: 'day' },
    { number: 30, unit: 'day' },
    { number: 12, unit: 'month' }
  ]
  const DEFAULT_METRIC = 'hits'
  const DEFAULT_STATE = { dateRange: new PeriodRangeDate(), selectedMetricName: DEFAULT_METRIC }

  function renderDateRangeSelector (statsState, settings) {
    new StatsMenu({
      statsState,
      periods: DEFAULT_PERIODS,
      granularities: settings.granularities,
      container: settings.menuContainer}).render()
  }

  function renderApplicationSelector (statsState, settings) {
    new StatsApplicationsSelector({
      statsState,
      applicationGroups: settings.applicationGroups,
      container: settings.applicationsSelectorContainer
    }).render()
  }

  function groupMetrics (list, settings) {
    const sortedMetrics = list.metrics.sort((a, b) => (b.serviceId || 0) - (a.serviceId || 0))
    const methodsByMetric = metric => [metric, ...list.methods.filter(method => method.parentId === metric.id)]
    return settings.hasGroupedMethods ? sortedMetrics : sortedMetrics.flatMap(methodsByMetric)
  }

  return {
    build: function ({ id, selectedState = {}, metrics, widgets = [], options = {} }) {
      const DEFAULTS = {
        chartContainer: '#chart',
        selectorContainer: '.StatsSelector-container',
        menuContainer: '.StatsMenu-container',
        hasMenu: true,
        applicationsSelectorContainer: '.StatsApplicationsSelectorContainer',
        hasApplicationsSelector: false,
        applicationGroups: {},
        granularities: ['hour', 'day', 'month'],
        hasGroupedMethods: true,
        isSourceCollector: true,
        timezone: undefined
      }
      let settings = Object.assign({}, DEFAULTS, options)
      let store = new StatsStore(window.top)
      let statsState = new StatsState(store, Object.assign({}, DEFAULT_STATE, selectedState))

      metrics.then(list => {
        const groupedMetrics = groupMetrics(list, settings)
        let metricsSelector = new StatsMetricsSelector({statsState, metrics: groupedMetrics, container: settings.selectorContainer})
        widgets.forEach(widget => widget.render())
        let groupedMethods = settings.hasGroupedMethods ? list.methods.map(method => method.name) : null
        let chart = new Chart({container: settings.chartContainer, groupedSeries: groupedMethods})
        let sources = (settings.isSourceCollector) ? new Sources({id, metrics}) : [new Sources({id})]
        let chartManager = new ChartManager({
          statsState,
          metricsSelector,
          sources,
          chart,
          widgets
        })
        chart.registerManager(chartManager)
        chartManager.render()

        if (settings.hasMenu) renderDateRangeSelector(statsState, settings)

        if (settings.hasApplicationsSelector) renderApplicationSelector(statsState, settings)
      })
    }
  }
}
