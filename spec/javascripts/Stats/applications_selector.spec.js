import $ from 'jquery'

import { StatsApplicationsSelector } from 'Stats/lib/applications_selector'

describe('StatsApplicationsSelector', () => {
  let userSelectedState = {
    state: { selectedApplicationId: '42' },
    setState: () => {}
  }

  let applicationGroups = {
    'Dumplings': [{id: 666, name: 'Wan Tun App'}, {id: 42, name: 'Pierogi App'}],
    'Empanadas': [{id: 7, name: 'Argenta'}]
  }

  let applicationsSelector = new StatsApplicationsSelector({
    statsState: userSelectedState,
    applicationGroups,
    container: '#selector-container'
  })

  beforeEach(() => {
    document.body.innerHTML = '<div id="selector-container"></div>'
    applicationsSelector.render()
  })

  it('should render the right applications selector', () => {
    let selector = $('#selector-container .StatsApplicationSelector')
    expect(selector.html()).toEqual(
      '<optgroup label="Dumplings"><option value="666">Wan Tun App</option><option value="42">Pierogi App</option></optgroup>' +
      '<optgroup label="Empanadas"><option value="7">Argenta</option></optgroup>'
    )
  })

  it('should have the correct application selected', () => {
    expect($('.StatsApplicationSelector option[value="42"]').prop('selected')).toBe(true)
  })

  it('should set the application id on the state when changing the dropdown and default metric', () => {
    jest.spyOn(userSelectedState, 'setState')
    $('.StatsApplicationSelector').val('666').trigger('change')

    expect(userSelectedState.setState).toHaveBeenCalledWith({selectedApplicationId: '666', selectedMetricName: 'hits'}, ['applicationSelected'])
  })
})
