/* eslint-disable @typescript-eslint/explicit-function-return-type */
/* eslint-disable @typescript-eslint/explicit-member-accessibility */
import { StatsStore } from 'Stats/lib/store'

describe('StatsStore', () => {
  class FakeHistory {
    state

    pushState (state) {
      this.state = state
    }
  }

  const window = {
    location: {
      hash: '#%7B%22period%22:%7B%22number%22:24,%22unit%22:%22hour%22%7D,%22granularity%22:%22hour%22%7D'
    },
    history: new FakeHistory()
  }
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

  it('should call triggerNavigationEvent method when popstate event is triggered', () => {
    const onSpy = jest.spyOn($(window), 'on')
    const newStore = new StatsStore(window)
    const spyOnNavigation = jest.spyOn(newStore, 'triggerNavigationEvent')

    const popstateCallback = onSpy.mock.calls.find(([event]) => event === 'popstate')?.[1]
    popstateCallback()

    expect(spyOnNavigation).toHaveBeenCalled()

    onSpy.mockRestore()
  })
})
