import { mount } from 'enzyme'
import c3 from 'c3'

import * as utils from 'utilities/fetchData'
import { InlineChart } from 'Stats/inlinechart'
import { waitForPromises } from 'utilities/test-utils'

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

// Mocking fetchData
const data = {
  total: 10,
  metric: {
    unit: 'hit'
  },
  values: [1, 2, 3]
}
const fetchMock = jest.spyOn(utils, 'fetchData')
  .mockImplementation(() => Promise.resolve(data))

const defaultProps = {
  endPoint: '/fake/endpoint',
  metricName: 'hits',
  title: 'Hits',
  unitPluralized: 'hits'
}

const mountWrapper = () => mount(<InlineChart {...defaultProps} />)

it('should fetch data on mount only', async () => {
  const wrapper = mountWrapper()

  await waitForPromises(wrapper)
  expect(fetchMock).toHaveBeenCalledTimes(1)
})

it('should get a valid URL', async () => {
  const expectedSearch = `?metric_name=${defaultProps.metricName}&since=${mockSince}&until=${mockUntil}&granularity=day`
  const wrapper = mountWrapper()

  await waitForPromises(wrapper)
  expect(fetchMock).toHaveBeenCalledWith(expect.stringContaining(expectedSearch))
})

it('should generate chart', async () => {
  const wrapper = mountWrapper()

  await waitForPromises(wrapper)
  expect(c3.generate).toHaveBeenCalledWith(expect.any(Object))
})

it('should print the correct label depending on the total of data', async () => {
  const wrapper1 = mountWrapper()
  await waitForPromises(wrapper1)
  expect(wrapper1.find('.total').text()).toEqual('10 hits')

  jest.spyOn(utils, 'fetchData')
    .mockImplementationOnce(() => Promise.resolve({ ...data, total: 0 }))
  const wrapper2 = mountWrapper()
  await waitForPromises(wrapper2)
  expect(wrapper2.find('.total').text()).toEqual('0 hits')

  jest.spyOn(utils, 'fetchData')
    .mockImplementationOnce(() => Promise.resolve({ ...data, total: 1 }))
  const wrapper3 = mountWrapper()
  await waitForPromises(wrapper3)
  expect(wrapper3.find('.total').text()).toEqual('1 hit')
})
