import * as helpers from 'stats/lib/stats_helpers'

describe('getPeriodFromDateRange', () => {
  it('should get the right period from any date range', () => {
    let todayDateRange = { since: '2016-02-16T08:00:00', until: '2016-02-17T07:59:59', granularity: 'hour' }
    let threeDaysDateRange = { since: '2016-02-01T08:00:00', until: '2016-02-03T07:59:59', granularity: 'hour' }
    let twoWeeksDateRange = { since: '2016-12-05T08:00:00', until: '2016-12-19T07:59:59', granularity: 'day' }
    let threeMonthsDateRange = { since: '2015-12-16T08:00:00', until: '2016-02-17T07:59:59', granularity: 'month' }
    let yearlyDateRange = { since: '2015-04-16T08:00:00', until: '2016-04-16T08:00:00', granularity: 'month' }

    expect(helpers.getPeriodFromDateRange(todayDateRange)).toBe('day')
    expect(helpers.getPeriodFromDateRange(threeDaysDateRange)).toBe('week')
    expect(helpers.getPeriodFromDateRange(twoWeeksDateRange)).toBe('month')
    expect(helpers.getPeriodFromDateRange(threeMonthsDateRange)).toBe('year')
    expect(helpers.getPeriodFromDateRange(yearlyDateRange)).toBe('year')
  })
})
