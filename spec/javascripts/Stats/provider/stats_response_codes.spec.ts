import $ from 'jquery'

import { StatsResponseCodeSource, StatsResponseCodeChart } from 'Stats/provider/stats_response_codes'

const metric = { system_name: '2XX' }
const options = {
  dateRange: {
    since: '2015-08-25',
    until: '2015-08-26',
    granularity: 'hour'
  }
}

describe('StatsResponseCodeSource', () => {
  const responseSource = new StatsResponseCodeSource({ id: 42, details: metric })

  it('should return the right url', () => {
    expect(responseSource.url).toEqual('/stats/api/services/42/usage_response_code.json')
  })

  it('should return the right params', () => {
    expect(responseSource.params(options)).toEqual({
      response_code: '2XX',
      since: '2015-08-25',
      until: '2015-08-26',
      granularity: 'hour',
      skip_change: true
    })
  })
})

describe('StatsResponseCodeChart', () => {
  beforeEach(() => {
    document.body.innerHTML = '<div id="chart"></div><div id="no-data">No data here mate!</div>'
  })

  it.todo('Update Chart tests')

  it.skip('shows no data message when no data available', () => {
    const fakeState = {
      state: {
        code: '2XX, 4XX',
        dateRange: {
          since: '1986-07-29T16:00:00+00:00',
          until: '1986-07-28T16:00:00+00:00',
          granularity: 'hour'
        }
      }
    }
    const chart = new StatsResponseCodeChart({ container: '#chart', statsState: fakeState })
    const data = {
      columns: [
        [
          'x',
          '2016-08-21T07:00:00'
        ],
        [
          'Hits',
          0
        ]
      ],
      unload: true,
      _totalValues: 0
    }
    chart.render({ noDataMessageContainer: '#no-data', data })
    const noDataMessage = $(chart.noDataMessageContainer)

    chart.showData(false)

    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore FIXME: why toContainText is not recognized?
    expect(noDataMessage).toContainText('No data \'ere mate!')
  })

  it.skip('should call setState with the right args when updateFromSeries', () => {
    const fakeState = jasmine.createSpyObj('fakeState', ['setState'])
    const chart = new StatsResponseCodeChart({ container: '#chart', statsState: fakeState })
    const series = '2XX, 4XX'
    const topics = ['cure']

    chart.updateFromSeries(series, topics)

    expect(fakeState.setState).toHaveBeenCalledWith({ code: series }, topics)
  })
})
