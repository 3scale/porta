import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

Enzyme.configure({ adapter: new Adapter() })

import InlineChart from 'Stats/inlinechart/index'
import c3 from 'c3'

// Mocking moment.js
const mockSince = '2018-11-17'
const mockUntil = '2018-12-17'
jest.mock('moment', () => () => ({
  format: () => mockUntil,
  subtract: () => {
    return {
      format: () => mockSince
    }
  }
}))

describe('<InlineChart/>', () => {
  let wrapper
  const props = {
    endPoint: '/fake/endpoint',
    metricName: 'hits',
    title: 'Hits',
    unitPluralized: 'hits'
  }

  beforeEach(() => {
    wrapper = mount(<InlineChart {...props}/>)
  })

  afterEach(() => {
    wrapper.unmount()
  })

  it('should mount with right props', () => {
    expect(wrapper.prop('endPoint')).toEqual(props.endPoint)
    expect(wrapper.prop('metricName')).toEqual(props.metricName)
    expect(wrapper.prop('title')).toEqual(props.title)
    expect(wrapper.prop('unitPluralized')).toEqual(props.unitPluralized)
  })

  it('should render HTML markup', () => {
    expect(wrapper.find('.loading').length).toEqual(1)
    expect(wrapper.find('.metric-name').length).toEqual(1)
    expect(wrapper.find('.total').length).toEqual(1)
    expect(wrapper.find('.inline-chart-graph').length).toEqual(1)
  })

  it('should fetch data from componentDidMount', async function () {
    global.fetch = jest.fn()
    wrapper.instance().componentDidMount()
    expect(global.fetch).toHaveBeenCalled()
  })

  it('should get a valid URL', () => {
    const expectedSearch = `?metric_name=${wrapper.prop('metricName')}&since=${mockSince}&until=${mockUntil}&granularity=day`
    const url = wrapper.instance().getURL()
    expect(url.origin).toBe(global.window.location.origin)
    expect(url.pathname).toBe(wrapper.prop('endPoint'))
    expect(url.search).toBe(expectedSearch)
  })

  it('should fail when fetching data from componentDidMount', async function () {
    global.fetch = jest.fn().mockImplementation(() => Promise.resolve({ok: false, status: '404', statusText: 'Not Found'}))
    wrapper.instance().componentDidMount()
    expect(wrapper.instance().throwError).toThrow()
  })

  it('should setState', () => {
    const mockData = {
      loading: false,
      title: 'Hits',
      total: '100 hits',
      values: [20, 20, 50, 10],
      unit: 'hits',
      unitPluralized: 'hits'
    }
    wrapper.setState(mockData)
    expect(wrapper.state().loading).toEqual(mockData.loading)
    expect(wrapper.state().title).toEqual(mockData.title)
    expect(wrapper.state().total).toEqual(mockData.total)
    expect(wrapper.state().values).toEqual(mockData.values)
    expect(wrapper.state().unit).toEqual(mockData.unit)
    expect(wrapper.state().unitPluralized).toEqual(mockData.unitPluralized)
  })

  it('calls updateState method with total of 1', () => {
    const data = {
      total: 1,
      metric: {
        unit: 'hit'
      }
    }

    wrapper.instance().generateC3Chart = jest.fn()
    wrapper.update()
    wrapper.instance().updateState(data)
    expect(wrapper.instance().generateC3Chart).toHaveBeenCalled()
  })

  it('calls updateState method with total > 1', () => {
    const data = {
      total: 10,
      metric: {
        unit: 'hit'
      }
    }
    wrapper.instance().generateC3Chart = jest.fn()
    wrapper.update()

    wrapper.instance().updateState(data)
    expect(wrapper.instance().generateC3Chart).toHaveBeenCalled()
  })

  it('should call c3.generate(), from generateC3Chart()', () => {
    c3.generate = jest.fn()
    wrapper.instance().generateC3Chart()
    expect(c3.generate).toHaveBeenCalled()
  })
})
