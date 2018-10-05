import {StatsTopAppsSeries} from '../../../app/javascript/src/Stats/provider/stats_top_apps'

describe('StatsTopApps', () => {
  describe('StatsTopAppsSeries', () => {
    let serie = {
      application: {
        account: {
          id: 42,
          name: 'Douglas Adams'
        },
        name: 'The Hitchhikkers Guide To The Galaxy'
      }
    }

    let statsTopAppsSeries = new StatsTopAppsSeries([])

    it('should return the correct serie name', () => {
      expect(statsTopAppsSeries._getSeriesName(serie)).toBe('The Hitchhikkers Guide To The Galaxy by Douglas Adams')
    })
  })
})
