// @flow

import React from 'react'

import { act } from 'react-dom/test-utils'
import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'NewApplication/components/NewApplicationForm'

const appPlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const servicePlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const products = [
  { id: '0', name: 'API Product', systemName: 'api-product', updatedAt: '1 Jan 2021', appPlans, servicePlans, defaultServicePlan: servicePlans[0] },
  { id: '1', name: 'API w/o plans', systemName: 'api-no-plans', updatedAt: '1 Jan 2021', appPlans, servicePlans, defaultServicePlan: null }
]
const buyer = {
  id: '12345',
  name: 'developer',
  admin: 'admin',
  createdAt: '1 Jan 2021',
  contractedProducts: [
    { id: 0, name: 'API Product', withPlan: appPlans[0] }
  ],
  createApplicationPath: '/account/12345/applications/new'
}
const buyers = [buyer]
const defaultProps = {
  createApplicationPath: '/applications/new',
  createApplicationPlanPath: '/accounts/applications/new',
  products,
  servicePlansAllowed: true,
  buyer,
  serviceSubscriptionsPath: '/foo'
}

const mountWrapper = (props) => mount(<NewApplicationForm {...{...defaultProps, ...props}}/>)
const renderWrapper = (props) => render(<NewApplicationForm {...{...defaultProps, ...props}}/>)

it('should render properly', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should render a link to create an application plan if selected product has none', () => {
  const wrapper = mountWrapper()
  const linkSelector = `a[href="${defaultProps.createApplicationPlanPath}"]`
  const productWithNoPlans = { ...products[0], appPlans: [] }
  expect(wrapper.find(linkSelector).exists()).toBe(false)

  act(() => wrapper.find('ProductSelect').props().onSelectProduct(productWithNoPlans))

  expect(wrapper.update().find(linkSelector).exists()).toBe(true)
})

it('should enable the plans select only after selecting a product', () => {
  const wrapper = mountWrapper()
  const planSelectSelector = 'Select#cinstance_plan_id .pf-c-select'
  expect(wrapper.find(planSelectSelector).find('.pf-m-disabled').exists()).toBe(true)

  act(() => wrapper.find('ProductSelect').props().onSelectProduct(products[0]))

  expect(wrapper.update().find(planSelectSelector).find('.pf-m-disabled').exists()).toBe(false)
})

describe('when in Service context', () => {
  const props = { ...defaultProps, buyer: undefined, buyers, product: products[0], products: undefined }

  it('should render all inputs but for product', () => {
    const inputs = [
      'account_id',
      'cinstance_service_plan_id',
      'cinstance_plan_id',
      'cinstance_name',
      'cinstance_description'
    ]
    const html = renderWrapper(props).find('.pf-c-form__group').toString()

    inputs.forEach(name => expect(html).toMatch(name))
    expect(html).not.toMatch('product')
  })

  it('should be able to submit only when form is complete', () => {
    const wrapper = mountWrapper(props)
    const isButtonDisabled = () => wrapper.update().find('button[type="submit"]').prop('disabled')
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('BuyerSelect').props().onSelectBuyer(buyer))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ServicePlanSelect').props().onSelect(servicePlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('NameInput').props().setName('My App'))
    wrapper.update()
    expect(isButtonDisabled()).toBe(false)
  })
})

describe('when in Account context', () => {
  const props = { ...defaultProps, buyer, buyers: undefined }

  it('should render all inputs but for buyer', () => {
    const inputs = [
      'product',
      'cinstance_service_plan_id',
      'cinstance_plan_id',
      'cinstance_name',
      'cinstance_description'
    ]
    const html = renderWrapper(props).find('.pf-c-form__group').toString()

    inputs.forEach(name => expect(html).toMatch(name))
    expect(html).not.toMatch('account_id')
  })

  it('should be able to submit only when form is complete', () => {
    const wrapper = mountWrapper(props)
    const isButtonDisabled = () => wrapper.update().find('button[type="submit"]').prop('disabled')
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ProductSelect').props().onSelectProduct(products[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ServicePlanSelect').props().onSelect(servicePlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('NameInput').props().setName('My App'))
    wrapper.update()
    expect(isButtonDisabled()).toBe(false)
  })
})

describe('when in Audience context', () => {
  const props = { ...defaultProps, buyer: undefined, buyers }

  it('should render all inputs', () => {
    const inputs = [
      'account_id',
      'product',
      'cinstance_service_plan_id',
      'cinstance_plan_id',
      'cinstance_name',
      'cinstance_description'
    ]
    const html = renderWrapper(props).find('.pf-c-form__group').toString()

    inputs.forEach(name => expect(html).toMatch(name))
  })

  it('should be able to submit only when form is complete', () => {
    const wrapper = mountWrapper(props)
    const isButtonDisabled = () => wrapper.update().find('button[type="submit"]').prop('disabled')
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('BuyerSelect').props().onSelectBuyer(buyer))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ProductSelect').props().onSelectProduct(products[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ServicePlanSelect').props().onSelect(servicePlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('NameInput').props().setName('My App'))
    wrapper.update()
    expect(isButtonDisabled()).toBe(false)
  })
})

it('should render a select for services provided they are allowed', () => {
  const wrapper = mountWrapper({ servicePlansAllowed: true })
  expect(wrapper.find('ServicePlanSelect').exists()).toBe(true)

  wrapper.setProps({ servicePlansAllowed: false })
  expect(wrapper.find('ServicePlanSelect').exists()).toBe(false)
})
