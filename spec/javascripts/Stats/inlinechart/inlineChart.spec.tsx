/* eslint-disable @typescript-eslint/require-await */
/* eslint-disable @typescript-eslint/init-declarations */
/* eslint-disable @typescript-eslint/promise-function-async */
import { mount } from 'enzyme'
import c3 from 'c3'

import * as utils from 'utilities/fetchData'
import InlineChart from 'Stats/inlinechart'

import type { Props, State } from 'Stats/inlinechart'
import type { ReactWrapper } from 'enzyme'

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

const data = {
  total: 10,
  metric: {
    unit: 'hit'
  },
  values: [1, 2, 3]
}
const fetchMock = jest.spyOn(utils, 'fetchData')
  .mockImplementation(() => Promise.resolve(data))

let wrapper: ReactWrapper<Props, State, InlineChart>
const props = {
  endPoint: '/fake/endpoint',
  metricName: 'hits',
  title: 'Hits',
  unitPluralized: 'hits'
}

beforeEach(() => {
  wrapper = mount(<InlineChart {...props} />)
})

afterEach(() => {
  fetchMock.mockClear()
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

it('should fetch data from componentDidMount', async () => {
  void wrapper.instance().componentDidMount()
  expect(fetchMock).toHaveBeenCalled()
})

it('should get a valid URL', () => {
  const expectedSearch = `?metric_name=${wrapper.prop('metricName')}&since=${mockSince}&until=${mockUntil}&granularity=day`
  const url = wrapper.instance().getURL()
  expect(url.origin).toBe(global.window.location.origin)
  expect(url.pathname).toBe(wrapper.prop('endPoint'))
  expect(url.search).toBe(expectedSearch)
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

it('should print the correct lebel depending on the total of data', () => {
  wrapper.instance().updateState({ ...data, total: 0 })
  expect(wrapper.state('total')).toEqual('0 hits')

  wrapper.instance().updateState({ ...data, total: 1 })
  expect(wrapper.state('total')).toEqual('1 hit')

  wrapper.instance().updateState({ ...data, total: 10 })
  expect(wrapper.state('total')).toEqual('10 hits')
})

it('should call c3.generate(), from generateC3Chart()', () => {
  c3.generate = jest.fn()
  wrapper.instance().generateC3Chart()
  expect(c3.generate).toHaveBeenCalled()
})
