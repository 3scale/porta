import $ from 'jquery'
import {render} from 'dashboard/chart'

describe('Chart', () => {
  let data = {
    values: { '2016-01-25': { 'value': 1, 'formatted_value': 99 } }
  }

  beforeEach(() => {
    let basicStructure = `
      <article class='DashboardWidget' id='widget1'>
        <p data-title-count>50</p>
        <p data-title-intro>last 30 days</p>
        <div data-chart class='Dashboard-chart'></div>
      </article>`

    fixture.set(basicStructure)
  })

  it('has a c3 chart', () => {
    render(fixture.el, data)

    expect(fixture.el).toContainElement('div.c3')
  })

  xit('has a different column for a incomplete part', () => {
    render(fixture.el, data)

    expect(fixture.el).toContainElement('rect[fill="transparent"]')
  })

  xit('should change text in the labels', () => {
    render(fixture.el, data)

    let lastColumn = $('#widget1').find('.c3-event-rect').last()

    expect(fixture.el).toContainText(50)
    expect(fixture.el).toContainText('last 30 days')

    lastColumn.trigger('mouseover')

    expect(fixture.el).toContainText(199)
    expect(fixture.el).toContainText('26 January 2016')

    lastColumn.trigger('mouseout')

    expect(fixture.el).toContainText(50)
    expect(fixture.el).toContainText('last 30 days')
  })
})
