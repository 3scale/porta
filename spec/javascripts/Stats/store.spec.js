import $ from 'jquery'

import {StatsStore} from '../../../app/javascript/src/Stats/lib/store'

describe('StatsStore', () => {
  class FakeHistory {
    pushState (state) {
      this.state = state
    }
  }

  let window = {
    location: {
      hash: '#%7B%22period%22:%7B%22number%22:24,%22unit%22:%22hour%22%7D,%22granularity%22:%22hour%22%7D'
    },
    history: new FakeHistory()
  }
  let store = new StatsStore(window)

  it('should update history', () => {
    let state = {
      granularity: 'hour',
      period: {
        number: 24,
        unit: 'hour'
      }
    }

    store.save(state)

    expect(store.window.history.state).toEqual(state)
  })

  it('should get params', () => {
    let params = store.load()

    expect(params).toEqual({
      period: {
        number: 24,
        unit: 'hour'
      },
      granularity: 'hour'
    })
  })

  it('should call triggerNavigationEvent method when popstate event is triggered', () => {
    let spyOnNavigation = spyOn(store, 'triggerNavigationEvent')

    $(store.window).triggerHandler('popstate')

    expect(spyOnNavigation).toHaveBeenCalled()
  })
})
