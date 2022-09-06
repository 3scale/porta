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
    pushState (state) {
      this.state = state
    }
  }

  class FakeState {
    constructor (store) {
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

    set dateRange (date) {
      this.state = date
      this.store.save(date)
    }

    get dateRange () {
      return this.state
    }

    setState (state) {
      this.state = Object.assign({}, this.state, state)
    }
  }

  describe('HTML', () => {
    beforeEach(() => {
      document.body.innerHTML = '<div id="menu"></div>'
    })

    let window = { history: new FakeHistory() }
    let store = new StatsStore(window)
    var statsState = new FakeState(store)
    let menu = new StatsMenu({ statsState, periods: PERIODS, container: '#menu' })

    beforeEach(() => {
      menu.render()
    })

    it('should render HTML', () => {
      let element = document.querySelector('#menu')

      expect(element.querySelectorAll('ol > li a[data-number][data-unit]')).toHaveLength(4)
      expect(element.querySelectorAll('select > option')).toHaveLength(3)
      expect(element.querySelector('select > option:first-child').value).toBe('hour')
    })

    it('should set the right period state', () => {
      let periodLink = document.querySelector('#menu .period-24-hour')
      periodLink.click()

      expect(menu.statsState.state.dateRange.granularity).toBe('hour')
      expect(menu.statsState.state.dateRange.period.number).toBe(24)
    })

    it('should set the right granularity when selected', () => {
      const menuElement = document.querySelector('#menu')
      const select = menuElement.querySelector('select')
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
      let window = {
        location: {
          hash: ''
        },
        history: new FakeHistory()
      }
      let store = new StatsStore(window)
      let statsState = new StatsState(store)
      let menu = new StatsMenu({ statsState, periods: PERIODS, container: '#menu' })

      menu.render()

      let periodLink = document.querySelector('#menu .period-24-hour')

      periodLink.click()

      expect(window.history.state.dateRange.granularity).toBe('hour')
      expect(window.history.state.dateRange.period.number).toBe(24)
    })

    it('should show the right menu when load from url', () => {
      let window = {
        location: {
          hash: '#{"dateRange":{"Since":"2015-08-01T00:00:00+00:00","Until":"2015-08-10T00:00:00+00:00","granularity":"hour"}}'
        }
      }
      let store = new StatsStore(window)
      let statsState = new StatsState(store)
      let menu = new StatsMenu({ statsState, periods: PERIODS, container: '#menu' })

      menu.render()
      menu.statsState.store.getStateFromURL()

      const statsMenu = document.querySelector('.StatsMenu')

      expect(statsMenu.querySelector('.StatsMenu-customLink--since').innerHTML).toBe('08/01/2015')
      expect(statsMenu.querySelector('.StatsMenu-customLink--until').innerHTML).toBe('08/10/2015')
    })
  })
})
