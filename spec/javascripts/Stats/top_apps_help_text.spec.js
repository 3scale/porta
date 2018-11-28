import $ from 'jquery'
import {StatsTopAppsHelpText} from 'Stats/provider/stats_top_apps'

describe('StatsTopAppsHelpText', () => {
  let helpText = new StatsTopAppsHelpText({container: '#container'})

  beforeEach(() => {
    fixture.set('<div id="container"></div>')
    helpText.render()
  })

  it('should display the correct selected period: day', () => {
    let dayPeriod = { _topAppsSelectionPeriod: { since: '2017-01-01T00:00:00+00:00', until: '2017-01-01T23:59:59+00:00', name: 'day' } }

    helpText.update(dayPeriod)
  })

  it('should display the correct selected period: week', () => {
    let weekPeriod = { _topAppsSelectionPeriod: { since: '2017-01-02T00:00:00+00:00', until: '2017-01-08T23:59:59+00:00', name: 'week' } }

    helpText.update(weekPeriod)
    expect($('.Stats-message--notice')).toContainText('Top Applications are determined from usage data between midnight 01/01/2017 and midnight 01/08/2017')
  })

  it('should display the correct selected period: month', () => {
    let monthPeriod = { _topAppsSelectionPeriod: { since: '2017-01-01T00:00:00+00:00', until: '2017-01-31T23:59:59+00:00', name: 'month' } }

    helpText.update(monthPeriod)
    expect($('.Stats-message--notice')).toContainText('Top Applications are determined from usage data between midnight 12/31/2016 and midnight 01/31/2017')
  })

  it('should display the correct selected period: year', () => {
    let yearPeriod = { _topAppsSelectionPeriod: { since: '2017-01-01T00:00:00+00:00', until: '2017-12-31T23:59:59+00:00', name: 'year' } }

    helpText.update(yearPeriod)
    expect($('.Stats-message--notice')).toContainText('Top Applications are determined from usage data between midnight 12/31/2016 and midnight 12/31/2017')
  })
})
