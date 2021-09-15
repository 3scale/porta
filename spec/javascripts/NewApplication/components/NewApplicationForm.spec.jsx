// @flow

import React from 'react'

import { act } from 'react-dom/test-utils'
import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'NewApplication/components/NewApplicationForm'

import * as alert from 'utilities/alert'
const errorSpy = jest.spyOn(alert, 'error')

const appPlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const servicePlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const products = [
  { id: '0', name: 'API Product', description: 'api-product', updatedAt: '1 Jan 2021', appPlans, servicePlans, defaultServicePlan: servicePlans[0] },
  { id: '1', name: 'API w/o plans', description: 'api-no-plans', updatedAt: '1 Jan 2021', appPlans, servicePlans }
]
const buyer = {
  id: '12345',
  name: 'developer',
  description: 'Admin: Mr. Admin',
  createdAt: '1 Jan 2021',
  contractedProducts: [{ id: 0, name: 'API Product', withPlan: appPlans[0] }],
  createApplicationPath: '/account/12345/applications/new'
}
const buyers = [buyer]
const defaultProps = {
  createApplicationPath: '/applications/new',
  createApplicationPlanPath: '/accounts/applications/new',
  createServicePlanPath: '/bar',
  serviceSubscriptionsPath: '/foo',
  product: undefined,
  mostRecentlyUpdatedProducts: products,
  productsCount: undefined,
  servicePlansAllowed: undefined,
  buyer,
  mostRecentlyCreatedBuyers: undefined,
  buyersCount: undefined,
  definedFields: undefined,
  validationErrors: {},
  error: undefined
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

describe('when the buyer can select a plan', () => {
  const product = { ...products[0], buyerCanSelectPlan: true }
  const mostRecentlyUpdatedProducts = [...products, product]

  it('should enable the plans select only after selecting a product', () => {
    const wrapper = mountWrapper({ mostRecentlyUpdatedProducts })
    const planSelectSelector = 'Select#cinstance_plan_id .pf-c-select'
    expect(wrapper.find(planSelectSelector).find('.pf-m-disabled').exists()).toBe(true)

    act(() => wrapper.find('ProductSelect').props().onSelectProduct(product))

    expect(wrapper.update().find(planSelectSelector).find('.pf-m-disabled').exists()).toBe(false)
  })
})

describe('when the buyer cannot select a plan', () => {
  const product = { ...products[0], buyerCanSelectPlan: true }
  const mostRecentlyUpdatedProducts = [...products, product]

  it('should not be able to select a plan even after selecting a product', () => {
    const wrapper = mountWrapper({ mostRecentlyUpdatedProducts })
    const planSelectSelector = 'Select#cinstance_plan_id .pf-c-select'
    expect(wrapper.find(planSelectSelector).find('.pf-m-disabled').exists()).toBe(true)

    act(() => wrapper.find('ProductSelect').props().onSelectProduct(product))

    expect(wrapper.update().find(planSelectSelector).find('.pf-m-disabled').exists()).toBe(false)
  })
})

it('should show an alert if there is an error', () => {
  const error = 'Something went wrong'
  mountWrapper({ error })

  expect(errorSpy).toHaveBeenCalledWith(error)
})

it('should not render a Service Plan select by default', () => {
  const html = renderWrapper().find('.pf-c-form__group').toString()
  expect(html).not.toMatch('service_plan_id')
})

describe('when in Service context', () => {
  const props = {
    ...defaultProps,
    buyer: undefined,
    mostRecentlyCreatedBuyers: buyers,
    product: products[0],
    mostRecentlyUpdatedProducts: undefined
  }

  it('should not render Product select', () => {
    const inputs = [
      'account_id',
      'cinstance_plan_id'
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

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(false)
  })
})

describe('when in Account context', () => {
  const props = {
    ...defaultProps,
    buyer,
    buyers: undefined,
    product: undefined,
    mostRecentlUpdatedProducts: products
  }

  it('should not render Buyer select', () => {
    const inputs = [
      'product',
      'cinstance_plan_id'
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

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(false)
  })
})

describe('when in Audience context', () => {
  const props = {
    ...defaultProps,
    buyer: undefined,
    mostRecentlyCreatedBuyers: buyers,
    product: undefined,
    mostRecentlyUpdatedProducts: products
  }

  it('should render all selects', () => {
    const inputs = [
      'account_id',
      'product',
      'cinstance_plan_id'
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

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
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

describe('when service plans are allowed', () => {
  const props = { servicePlansAllowed: true }

  it('should render a select for service plans', () => {
    const html = renderWrapper(props).find('.pf-c-form__group').toString()
    expect(html).toMatch('cinstance_service_plan_id')
  })

  it('should disable submit button until a service plan is selected', () => {
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
    expect(isButtonDisabled()).toBe(false)
  })
})

describe('when there are extra fields', () => {
  const definedFields = [
    {
      hidden: false,
      readOnly: false,
      required: true,
      label: 'Name',
      name: 'name',
      id: 'name',
      type: 'builtin'
    },
    {
      hidden: false,
      readOnly: false,
      required: true,
      label: 'State',
      name: 'state',
      id: 'state',
      choices: ['active', 'pending'],
      type: 'builtin'
    }
  ]

  it('should render all inputs', () => {
    const inputs = definedFields.map(field => field.name)
    const html = renderWrapper({ definedFields }).find('.pf-c-form__group').toString()

    inputs.forEach(name => expect(html).toMatch(name))
  })

  it('should be able to submit only when form is complete', () => {
    const wrapper = mountWrapper({ definedFields })
    const isButtonDisabled = () => wrapper.update().find('button[type="submit"]').prop('disabled')
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ProductSelect').props().onSelectProduct(products[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(appPlans[0]))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('UserDefinedField').at(0).props().onChange('My Name'))
    wrapper.update()
    expect(isButtonDisabled()).toBe(true)

    act(() => wrapper.find('UserDefinedField').at(1).props().onChange('Active'))
    wrapper.update()
    expect(isButtonDisabled()).toBe(false)
  })
})
