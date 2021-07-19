import $ from 'jquery'
import MockDate from 'mockdate'

import { StatsState, PeriodRangeDate, CustomRangeDate } from 'Stats/lib/state'

describe('StatsState', () => {
  const save = jest.fn()
  const fakeStore = {
    getStateFromURL: jest.fn(),
    save
  }

  let stubbedState = {
    dateRange: {
      period: {
        number: 7,
        unit: 'day'
      },
      granularity: 'day'
    }
  }

  let StubbedStore = {
    getStateFromURL () {
      return stubbedState
    }
  }

  it('should save the right state when calling setState', () => {
    let statsState = new StatsState(fakeStore)
    let state = {dateRange: {period: {number: 24, unit: 'hours'}}, code: '200'}

    statsState.setState(state)

    expect(save).toHaveBeenCalled()
    expect(JSON.stringify(statsState.state)).toBe(JSON.stringify(state))
  })

  it('should trigger the right events when setting the state', () => {
    let statsState = new StatsState(fakeStore)
    let state = {jesus: 'you dont fu*ck with the jaysus!'}
    let topics = ['jesus']

    const fakeFunction = jest.fn()
    statsState.fakeFunction = fakeFunction
    $(statsState).on('jesus', statsState.fakeFunction)

    statsState.setState(state, topics)

    expect(fakeFunction).toHaveBeenCalled()
  })

  it('should return the right state when loading from store', () => {
    let statsState = new StatsState(StubbedStore)

    expect(JSON.stringify(statsState.state)).toBe(JSON.stringify(stubbedState))
  })

  it('should return the correct state when no stored state provided', () => {
    let statsState = new StatsState(fakeStore)
    let dataRange = new PeriodRangeDate()

    expect(statsState.state).toEqual({ dateRange: dataRange })
  })

  it('should call setState when navigation event was triggered with the rigth params', () => {
    let statsState = new StatsState(fakeStore)
    let stubbedState = {milonga: true}
    jest.spyOn(statsState, 'setState')
    jest.spyOn(statsState, 'getStoredState').mockReturnValue(stubbedState)

    $(statsState.store).triggerHandler('navigation')

    expect(statsState.setState).toHaveBeenCalledWith(stubbedState, ['refresh'], false)
  })

  describe('State Date', () => {
    describe('PeriodRangeDate', () => {
      MockDate.set('1986-07-29T16:00:00Z')

      it('should return the correctly formatted timestamp by default', () => {
        let periodRangeDate = new PeriodRangeDate()
        // Period Range needs UTC Offset when granularity is hour in order to avoid asking for the future.
        expect(periodRangeDate.since).toBe('1986-07-28T17:00:00Z')
        expect(periodRangeDate.until).toBe('1986-07-29T16:00:00Z')
      })

      it('should return the timestamp without offset when granularity != hour', () => {
        let customPeriodGranularityHour = {
          number: 7,
          unit: 'day'
        }
        let periodRangeDate = new PeriodRangeDate(customPeriodGranularityHour)

        expect(periodRangeDate.since).toBe('1986-07-23T16:00:00')
        expect(periodRangeDate.until).toBe('1986-07-29T16:00:00')
      })
    })

    describe('CustomRangeDate', () => {
      it('should return the correct timestamp', () => {
        let customDateRange1 = new CustomRangeDate(
          {
            Since: '1986-07-29T16:00:00',
            Until: '1986-07-29T16:00:00',
            granularity: 'hour'
          })
        expect(customDateRange1.since).toBe('1986-07-29T00:00:00')
        expect(customDateRange1.until).toBe('1986-07-29T23:59:59')

        let customDateRange2 = new CustomRangeDate(
          {
            Since: '1986-07-29T16:00:00',
            Until: '2016-05-29T16:00:00',
            granularity: 'month'
          })
        // UTC Offset is stripped and sent from the beginning until the end of the day
        // The API will return the same beginning-end but will add the offset
        expect(customDateRange2.since).toBe('1986-07-29T00:00:00')
        expect(customDateRange2.until).toBe('2016-05-29T23:59:59')
      })
    })
  })
})
