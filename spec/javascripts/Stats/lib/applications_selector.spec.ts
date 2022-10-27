import { StatsApplicationsSelector } from 'Stats/lib/applications_selector'

import type { StatsState } from 'Stats/lib/state'

describe('StatsApplicationsSelector', () => {
  const userSelectedState = {
    state: { selectedApplicationId: '42' },
    setState: jest.fn()
  } as unknown as typeof StatsState

  const applicationGroups = {
    'Dumplings': [{ id: 666, name: 'Wan Tun App' }, { id: 42, name: 'Pierogi App' }],
    'Empanadas': [{ id: 7, name: 'Argenta' }]
  }

  const applicationsSelector = new StatsApplicationsSelector({
    statsState: userSelectedState,
    applicationGroups,
    container: '#selector-container'
  })

  beforeEach(() => {
    document.body.innerHTML = '<div id="selector-container"></div>'
    applicationsSelector.render()
  })

  it('should render the right applications selector', () => {
    const selector = document.querySelector('#selector-container .StatsApplicationSelector')!
    expect(selector.innerHTML).toEqual(
      '<optgroup label="Dumplings"><option value="666">Wan Tun App</option><option value="42">Pierogi App</option></optgroup>' +
      '<optgroup label="Empanadas"><option value="7">Argenta</option></optgroup>'
    )
  })

  it('should have the correct application selected', () => {
    expect(document.querySelector<any>('.StatsApplicationSelector option[value="42"]')!.selected).toBe(true)
  })

  it('should set the application id on the state when changing the dropdown and default metric', () => {
    jest.spyOn(userSelectedState, 'setState')
    const select = document.querySelector<HTMLInputElement>('.StatsApplicationSelector')!
    const event = new Event('change')
    select.value = '666'
    select.dispatchEvent(event)
    expect(userSelectedState.setState).toHaveBeenCalledWith({ selectedApplicationId: '666', selectedMetricName: 'hits' }, ['applicationSelected'])
  })
})
