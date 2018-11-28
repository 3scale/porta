import $ from 'jquery'

import {StatsAverageMetricsSource} from 'Stats/lib/average_metrics_source'

describe('StatsAverageMetricsSource', () => {
  describe('StatsAverageMetricsSource Methods', () => {
    it('_sortValues', () => {
      let averageSerieSource = new StatsAverageMetricsSource(42, {})
      let map = new Map([
        [1, 30], [2, 30], [3, 30], [4, 30], [5, 30], [6, 30],
        [7, 30], [8, 30], [9, 30], [10, 30], [11, 30], [12, 30],
        [13, 30], [14, 30], [15, 30], [16, 30], [17, 30], [18, 30],
        [19, 30], [20, 30], [21, 30], [22, 30], [23, 30], [0, 30]
      ])
      expect(JSON.stringify(averageSerieSource._sortValues(map))).toBe(
        '[30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30]'
      )
    })

    it('_average', () => {
      let averageSerieSource = new StatsAverageMetricsSource(42, {})
      let responseValues = [0, 10, 22, 33, 42, 55, 60, 77, 80, 99, 100, 111,
        11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0] // 24 months
      let stateOptions = {
        dateRange: {
          since: '2014-01-01T00:00:00-00:00',
          until: '2015-12-31T23:59:59-00:00',
          granularity: 'month'
        }
      }

      expect(JSON.stringify(averageSerieSource._average(responseValues, stateOptions)))
        .toBe('[1,2,3,4,5,6,6,7,7,9,9,10]')
    })
  })

  describe('StatsAverageMetricsSource Integration', () => {
    let selectedStateOptions = {
      dateRange: {
        since: '2016-02-01T00:00:00',
        until: '2016-02-02T23:59:59',
        granularity: 'hour'
      },
      selectedMetricName: 'hits'
    }
    let serie = {}

    let averageSerieSource = new StatsAverageMetricsSource(42, serie)

    let stubbedValues = [
      10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, // 24 hours
      20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10, 20, 10 // 24 hours
    ]

    beforeEach((done) => {
      spyOn($, 'getJSON').and.callFake(() => {
        return $.Deferred().resolve({
          values: stubbedValues,
          period: {
            since: '2016-02-01T00:00:00-07:00',
            until: '2016-02-02T23:59:59-07:00'
          },
          total: 720
        })
      })
      done()
    })

    it('should get the correct average data', (done) => {
      let expectedResponse = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      averageSerieSource.data(selectedStateOptions).then((response) => {
        expect(JSON.stringify(response.values)).toBe(JSON.stringify(expectedResponse))
        done()
      })
    })
  })
})
