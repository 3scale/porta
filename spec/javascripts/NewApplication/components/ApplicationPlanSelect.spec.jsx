// @flow

import React from 'react'

import { ApplicationPlanSelect } from 'NewApplication'
import { mount } from 'enzyme'

import type { Product, ApplicationPlan } from 'NewApplication/types'

const appPlan: ApplicationPlan = { id: 0, name: 'The Plan' }
const createApplicationPlanPath = '/plans'
const defaultProps = {
  product: null,
  appPlan: null,
  createApplicationPlanPath,
  onSelect: jest.fn()
}

const mountWrapper = (props) => mount(<ApplicationPlanSelect {...{ ...defaultProps, ...props }} />)

const expectToBeDisabled = (wrapper, isDisabled = true) => {
  expect(wrapper.find('.pf-c-select .pf-m-disabled').exists()).toBe(isDisabled)
  expect(wrapper.find('input.pf-c-select__toggle-typeahead').props().disabled).toBe(isDisabled)
  expect(wrapper.find('button.pf-c-select__toggle-button').props().disabled).toBe(isDisabled)
}

describe('when no product selected', () => {
  const props = { product: null }

  it('should be disabled when no product is selected', () => {
    const wrapper = mountWrapper(props)
    expectToBeDisabled(wrapper)
  })
})

describe('when a product is selected', () => {
  const product: Product = {
    id: 0,
    name: 'API Product',
    systemName: 'api-product',
    updatedAt: '1 Jan 2021',
    appPlans: [{ id: 0, name: 'The Plan' }],
    servicePlans: [],
    buyerCanSelectPlan: false,
    defaultServicePlan: null,
    defaultAppPlan: null
  }

  describe('and buyer can select plan', () => {
    const productCanSelectPlan = { ...product, buyerCanSelectPlan: true }
    const props = { product: productCanSelectPlan }

    it('should not be disabled', () => {
      const wrapper = mountWrapper(props)
      expectToBeDisabled(wrapper, false)
    })

    describe('and the product has some application plans', () => {
      const props = { product: { ...productCanSelectPlan, appPlans: [appPlan] } }

      it('should not be disabled', () => {
        const wrapper = mountWrapper(props)
        expectToBeDisabled(wrapper, false)
      })
    })

    describe('but the product has no application plans', () => {
      const props = { product: { ...productCanSelectPlan, appPlans: [] } }

      it('should show a hint with a link to create a plan', () => {
        const wrapper = mountWrapper(props)
        const hint = wrapper.find('.hint')
        expect(hint.exists()).toBe(true)
        expect(hint.find('a').props().href).toEqual(createApplicationPlanPath)
      })

      it('should be disabled', () => {
        const wrapper = mountWrapper(props)
        expectToBeDisabled(wrapper)
      })
    })
  })

  describe('and buyer cannot select plan', () => {
    const props = { product: { ...product, buyerCanSelectPlan: false } }

    it('should be disabled', () => {
      const wrapper = mountWrapper(props)
      expectToBeDisabled(wrapper)
    })
  })
})
