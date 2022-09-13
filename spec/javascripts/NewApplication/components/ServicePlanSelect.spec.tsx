import React from 'react'

import { ServicePlanSelect } from 'NewApplication'
import { mount } from 'enzyme'

const defaultProps = {
  servicePlan: null,
  servicePlans: null,
  onSelect: jest.fn(),
  isPlanContracted: false,
  isDisabled: undefined,
  serviceSubscriptionsPath: '/foo',
  createServicePlanPath: '/bar'
} as const

const mountWrapper = (props) => mount(<ServicePlanSelect {...{ ...defaultProps, ...props }} />)

const expectToBeDisabled = (wrapper: ReactWrapper<any>, isDisabled = true) => {
  expect(wrapper.find('.pf-c-select .pf-m-disabled').exists()).toBe(isDisabled)
  expect(wrapper.find('input.pf-c-select__toggle-typeahead').props().disabled).toBe(isDisabled)
  expect(wrapper.find('button.pf-c-select__toggle-button').props().disabled).toBe(isDisabled)
}

it('should be disabled', () => {
  const wrapper = mountWrapper({ isDisabled: true })
  expectToBeDisabled(wrapper)
})

describe('when plan is contracted', () => {
  const props = { ...defaultProps, isPlanContracted: true } as const

  it('should show a hint and be disabled', () => {
    const wrapper = mountWrapper(props)
    expectToBeDisabled(wrapper)
    expect(wrapper.find('.hint').exists()).toBe(true)
    expect(wrapper.find('.hint').find('a').prop('href')).toEqual(props.serviceSubscriptionsPath)
  })
})

describe('when plan is not contracted', () => {
  describe('and there are some plans', () => {
    const props = { ...defaultProps, isPlanContracted: false, servicePlans: [{ id: 0, name: 'service plan' }] } as const

    it('should show a hint', () => {
      const wrapper = mountWrapper(props)
      expectToBeDisabled(wrapper, false)
      expect(wrapper.find('.hint').exists()).toBe(true)
      expect(wrapper.find('.hint').find('a').exists()).toBe(false)
    })
  })

  describe('and there are no plans', () => {
    const props = { ...defaultProps, isPlanContracted: false, servicePlans: [] } as const

    it('should show a hint and a link to create a new plan', () => {
      const wrapper = mountWrapper(props)
      expectToBeDisabled(wrapper, false)
      expect(wrapper.find('.hint').exists()).toBe(true)
      expect(wrapper.find('.hint').find('a').prop('href')).toEqual(props.createServicePlanPath)
    })
  })

  describe('and plans is null', () => {
    const props = { ...defaultProps, isPlanContracted: false, servicePlans: null } as const

    it('should show a hint and a link to create a new plan', () => {
      const wrapper = mountWrapper(props)
      expectToBeDisabled(wrapper, false)
      expect(wrapper.find('.hint').exists()).toBe(true)
      expect(wrapper.find('.hint').find('a').exists()).toBe(false)
    })
  })
})
