import { StatsMenu } from 'Stats/lib/menu'
import { StatsStore } from 'Stats/lib/store'
import { StatsState } from 'Stats/lib/state'

describe('StatsMenu', () => {
  const PERIODS = [
    { number: 24, unit: 'hour' },
    { number: 7, unit: 'day' },
    { number: 30, unit: 'day' },
    { number: 12, unit: 'month' }
  ]

  class FakeHistory {
    private state: unknown

    public pushState (state: unknown) {
      this.state = state
    }
  }

  class FakeState {
    private readonly store: { save: (save: unknown) => void }

    private state: unknown

    public constructor (store: { save: (save: unknown) => void }) {
      this.store = store
      this.state = {
        dateRange: {
          period: {
            number: 24,
            unit: 'hour'
          },
          granularity: 'hour'
        }
      }
    }

    public get dateRange () {
      return this.state
    }

    public set dateRange (date) {
      this.state = date
      this.store.save(date)
    }

    public setState (state: typeof StatsState['state']) {
      this.state = Object.assign({}, this.state, state)
    }
  }

  describe('HTML', () => {
    beforeEach(() => {
      document.body.innerHTML = '<div id="menu"></div>'
    })

    const window = { history: new FakeHistory() } as unknown as Window
    const store = new StatsStore(window)
    const statsState = new FakeState(store)
    const menu = new StatsMenu({ statsState, periods: PERIODS, container: '#menu' })

    beforeEach(() => {
      menu.render()
    })

    it('should render HTML', () => {
      const element = document.querySelector('#menu')!

      expect(element.querySelectorAll('ol > li a[data-number][data-unit]')).toHaveLength(4)
      expect(element.querySelectorAll('select > option')).toHaveLength(3)
      expect(element.querySelector<HTMLInputElement>('select > option:first-child')!.value).toBe('hour')
    })

    it('should set the right period state', () => {
      const periodLink = document.querySelector<HTMLButtonElement>('#menu .period-24-hour')!
      periodLink.click()

      expect(menu.statsState.state.dateRange.granularity).toBe('hour')
      expect(menu.statsState.state.dateRange.period.number).toBe(24)
    })

    it('should set the right granularity when selected', () => {
      const menuElement = document.querySelector('#menu')!
      const select = menuElement.querySelector('select')!
      select.querySelectorAll('option')[2].selected = true

      const event = new Event('change')
      select.dispatchEvent(event)

      expect(menu.statsState.state.dateRange.granularity).toBe('month')
    })
  })

  describe('URL', () => {
    beforeEach(() => {
      document.body.innerHTML = '<div id="menu"></div>'
    })

    it('should update URL when period is selected', () => {
      const window = {
        location: {
          hash: ''
        },
        history: new FakeHistory()
      } as unknown as Window
      const store = new StatsStore(window)
      const statsState = new StatsState(store)
      const menu = new StatsMenu({ statsState, periods: PERIODS, container: '#menu' })

      menu.render()

      const periodLink = document.querySelector<HTMLButtonElement>('#menu .period-24-hour')!

      periodLink.click()

      expect(window.history.state.dateRange.granularity).toBe('hour')
      expect(window.history.state.dateRange.period.number).toBe(24)
    })

    it('should show the right menu when load from url', () => {
      const window = {
        location: {
          hash: '#{"dateRange":{"Since":"2015-08-01T00:00:00+00:00","Until":"2015-08-10T00:00:00+00:00","granularity":"hour"}}'
        }
      }
      const store = new StatsStore(window as Window)
      const statsState = new StatsState(store)
      const menu = new StatsMenu({ statsState, periods: PERIODS, container: '#menu' })

      menu.render()
      menu.statsState.store.getStateFromURL()

      const statsMenu = document.querySelector('.StatsMenu')!

      expect(statsMenu.querySelector('.StatsMenu-customLink--since')!.innerHTML).toBe('08/01/2015')
      expect(statsMenu.querySelector('.StatsMenu-customLink--until')!.innerHTML).toBe('08/10/2015')
    })
  })
})
