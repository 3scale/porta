// @flow

import React from 'react'

import { NewAccountsWidget } from 'Dashboard/components/NewAccountsWidget'
import { mount } from 'enzyme'

const defaultProps = {
  chartData: {
    values: {
      '2022-01-01': { value: 0, formatted_value: '0' },
      '2022-01-02': { value: 1, formatted_value: '1' },
      '2022-01-03': { value: 1, formatted_value: '1' }
    },
    complete: {
      '2022-01-01': { value: 0, formatted_value: '0' },
      '2022-01-02': { value: 1, formatted_value: '1' },
      '2022-01-03': { value: 1, formatted_value: '1' }
    },
    incomplete: {
      '2022-01-01': { value: 0, formatted_value: '0' },
      '2022-01-02': { value: 1, formatted_value: '1' },
      '2022-01-03': { value: 1, formatted_value: '1' }
    },
    previous: {
      '2022-01-01': { value: 0, formatted_value: '0' },
      '2022-01-02': { value: 1, formatted_value: '1' },
      '2022-01-03': { value: 1, formatted_value: '1' }
    }
  },
  newAccountsTotal: 10,
  hasHistory: true,
  links: {
    previousRangeAdminBuyersAccount: {
      url: '/buyers/accounts?search%5Bcreated_within%5D%5B%5D=2021-11-03&search%5Bcreated_within%5D%5B%5D=2021-12-03',
      value: '0'
    },
    currentRangeAdminBuyersAccount: {
      url: '/buyers/accounts?search%5Bcreated_within%5D%5B%5D=2021-12-03&search%5Bcreated_within%5D%5B%5D=2022-01-03'
    },
    lastDayInRangeAdminBuyersAccount: {
      url: '/buyers/accounts?search%5Bcreated_within%5D%5B%5D=2022-01-03&search%5Bcreated_within%5D%5B%5D=2022-01-03',
      value: '0'
    }
  },
  percentualChange: 50
}

const mountWrapper = (props) => mount(<NewAccountsWidget {...{ ...defaultProps, ...props }}/>)

it('should render', () => {
  const wrapper = mountWrapper(defaultProps)

  expect(wrapper.exists()).toBe(true)
})

describe('when there is historical data', () => {
  describe('and the percentual change is positive', () => {
    it('should render past data', () => {
      const wrapper = mountWrapper(defaultProps)

      expect(wrapper.find('.DashboardWidget-link.u-plus').exists()).toBe(true)
    })
  })

  describe('and the percentual change is negative or 0', () => {
    it('should render past data', () => {
      let props = { ...defaultProps, percentualChange: 0 }
      const wrapper = mountWrapper(props)

      expect(wrapper.find('.DashboardWidget-link.u-minus').exists()).toBe(true)
    })
  })

  it('should render past data label', () => {
    const wrapper = mountWrapper(defaultProps)

    expect(wrapper.text().includes('vs. previous 30 days')).toBe(true)
  })
})

describe('when there is no historical data', () => {
  it('should render current data', () => {
    let props = { ...defaultProps, hasHistory: false }
    const wrapper = mountWrapper(props)

    expect(wrapper.find('.DashboardWidget-link--today').exists()).toBe(true)
  })

  it('should render current data label', () => {
    let props = { ...defaultProps, hasHistory: false }
    const wrapper = mountWrapper(props)

    expect(wrapper.text().includes('today')).toBe(true)
  })
})
