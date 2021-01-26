// @flow

import React from 'react'

import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'Applications/components/NewApplicationForm'

const appPlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const servicePlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const products = [
  { id: 0, name: 'API Product', appPlans, servicePlans, defaultServicePlan: servicePlans[0] },
  { id: 1, name: 'API w/o plans', appPlans, servicePlans, defaultServicePlan: null }
]
const buyer = {
  id: '12345',
  name: 'developer',
  contractedProducts: [],
  servicePlans: [],
  createApplicationPath: '/account/12345/applications/new',
}

const defaultProps = {
  createApplicationPath: '/applications/new',
  createServicePlanPath: '/service/:id/plans/new',
  createApplicationPlanPath: '/accounts/applications/new',
  products,
  servicePlansAllowed: false
}

it('should render properly', () => {
  const wrapper = mount(<NewApplicationForm {...defaultProps} />)
  expect(wrapper.exists()).toBe(true)
})

it('should be able to submit only when form is complete', () => {
  const wrapper = mount(<NewApplicationForm {...defaultProps} />)
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)

  // FIXME:
  // wrapper.find('input[name="cinstance[name]"]').simulate('change', { currentTarget: { value: 'My Application' } })
  // wrapper.find('select#product').simulate('change', { target: { value: products[0].id } })
  // wrapper.find('select[name="cinstance[plan_id]"]').simulate('change', applicationPlans[0].id)
  // expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(false)
})

it('should render a link to create an application plan if selected product has none', () => {
  const wrapper = mount(<NewApplicationForm {...defaultProps} />)
  const getLink = () => wrapper.find(`a[href="${defaultProps.createApplicationPlanPath}"]`)
  expect(getLink().exists()).toBe(false)

  // FIXME:
  // wrapper.find('select#product').simulate('change', products[1].id)
  // expect(wrapper.find(`a[href="${defaultProps.createApplicationPlanPath}"]`).exists()).toBe(true)
})

it('should enable the plans select only after selecting a product', () => {
  const wrapper = mount(<NewApplicationForm {...defaultProps} />)
  const planSelect = wrapper.find('select[name="cinstance[plan_id]"]')
  expect(planSelect.prop('disabled')).toBe(true)

  // FIXME:
  // const productSelect = wrapper.find('select#product')
  // productSelect.simulate('change', products[0].id)

  // expect(planSelect.prop('disabled')).toBe(false)
  // console.log(planSelect.prop('disabled'))
})

describe('when in Account context', () => {
  const props = { ...defaultProps, buyer }

  it('should not render a select for Buyers', () => {
    const wrapper = render(<NewApplicationForm {...props} />)
    expect(wrapper.toString()).not.toContain('name="account_id"')
  })
})

describe('when in Applications context', () => {
  const props = { ...defaultProps, buyer: undefined }

  it('should render a select for Buyers', () => {
    const wrapper = render(<NewApplicationForm {...props} />)
    expect(wrapper.toString()).toContain('name="account_id"')
  })
})

describe('when Service plans not allowed', () => {
  const props = { ...defaultProps, servicePlansAllowed: false }
})

describe('when Service plans allowed', () => {
  const props = { ...defaultProps, servicePlansAllowed: true }
})
