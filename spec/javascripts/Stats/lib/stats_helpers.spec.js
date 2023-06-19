import * as helpers from 'Stats/lib/stats_helpers'

describe('getPeriodFromDateRange', () => {
  it('should get the right period from any date range', () => {
    const todayDateRange = { since: '2016-02-16T08:00:00', until: '2016-02-17T07:59:59', granularity: 'hour' }
    const threeDaysDateRange = { since: '2016-02-01T08:00:00', until: '2016-02-03T07:59:59', granularity: 'hour' }
    const twoWeeksDateRange = { since: '2016-12-05T08:00:00', until: '2016-12-19T07:59:59', granularity: 'day' }
    const threeMonthsDateRange = { since: '2015-12-16T08:00:00', until: '2016-02-17T07:59:59', granularity: 'month' }
    const yearlyDateRange = { since: '2015-04-16T08:00:00', until: '2016-04-16T08:00:00', granularity: 'month' }

    expect(helpers.getPeriodFromDateRange(todayDateRange)).toBe('day')
    expect(helpers.getPeriodFromDateRange(threeDaysDateRange)).toBe('week')
    expect(helpers.getPeriodFromDateRange(twoWeeksDateRange)).toBe('month')
    expect(helpers.getPeriodFromDateRange(threeMonthsDateRange)).toBe('year')
    expect(helpers.getPeriodFromDateRange(yearlyDateRange)).toBe('year')
  })
})
