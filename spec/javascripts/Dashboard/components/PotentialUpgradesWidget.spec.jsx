// @flow

import React from 'react'

import { PotentialUpgradesWidget } from 'Dashboard/components/PotentialUpgradesWidget'
import { mount } from 'enzyme'

let props
const defaultProps = {
  violations: [
    {
      id: 1,
      account_id: 1,
      account_name: 'Account Name',
      alerts_count: 10,
      url: '/apiconfig/alerts?search%5Baccount_id%5D=1&search%5Blevel%5D=100&search%5Btimestamp%5D%5B%5D=2022-09-24&search%5Btimestamp%5D%5B%5D=2022-10-24'
    }
  ],
  incorrectSetUp: true,
  links: {
    adminServiceApplicationPlans: '/apiconfig/services/1/application_plans',
    settingsAdminService: '/apiconfig/services/1/settings#web_provider'
  }
}

const mountWrapper = (props) => mount(<PotentialUpgradesWidget {...{ ...defaultProps, ...props }}/>)

it('should render', () => {
  const wrapper = mountWrapper(defaultProps)

  expect(wrapper.exists()).toBe(true)
})

describe('when the setup is incorrect', () => {
  it('should render incorrect setup messages', () => {
    const wrapper = mountWrapper(defaultProps)

    expect(wrapper.text().includes('In order to show Potential Upgrades, add 1 or more usage limits to')).toBe(true)
    expect(wrapper.text().includes('Web Alerts for Admins of this Account of 100%')).toBe(true)
  })
})

describe('when the setup is correct', () => {
  describe('and there are violations', () => {
    it('should render a list of violations', () => {
      let props = { ...defaultProps, incorrectSetUp: false }
      const wrapper = mountWrapper(props)

      expect(wrapper.find('.DashboardWidgetList').exists()).toBe(true)
      expect(wrapper.find('.DashboardWidgetList-item').exists()).toBe(true)
    })
  })

  describe('and there are no violations', () => {
    let props = { ...defaultProps, incorrectSetUp: false, violations: 0 }
    const wrapper = mountWrapper(props)

    it('should render a default message', () => {
      expect(wrapper.text().includes('No Potential Upgrades. Yet…')).toBe(true)
    })
  })
})
