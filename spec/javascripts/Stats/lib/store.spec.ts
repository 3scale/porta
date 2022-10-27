/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/explicit-function-return-type */
/* eslint-disable @typescript-eslint/explicit-member-accessibility */
import $ from 'jquery'

import { StatsStore } from 'Stats/lib/store'

describe('StatsStore', () => {
  class FakeHistory {
    state!: typeof StatsStore

    pushState (state: typeof StatsStore) {
      this.state = state
    }
  }

  const window = {
    location: {
      hash: '#%7B%22period%22:%7B%22number%22:24,%22unit%22:%22hour%22%7D,%22granularity%22:%22hour%22%7D'
    },
    history: new FakeHistory()
  } as unknown as Window
  const store = new StatsStore(window)

  it('should update history', () => {
    const state = {
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
    const params = store.load()

    expect(params).toEqual({
      period: {
        number: 24,
        unit: 'hour'
      },
      granularity: 'hour'
    })
  })

  // Todo: Implementation depends a lot on jQuery, testing without jQuery may require a refactor
  it('should call triggerNavigationEvent method when popstate event is triggered', () => {
    const spyOnNavigation = jest.spyOn(store, 'triggerNavigationEvent')

    $(store.window).triggerHandler('popstate')

    expect(spyOnNavigation).toHaveBeenCalled()
  })
})
