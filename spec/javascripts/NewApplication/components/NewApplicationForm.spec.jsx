// @flow

import React from 'react'

import { act } from 'react-dom/test-utils'
import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'NewApplication/components/NewApplicationForm'
import { isSubmitDisabled } from 'utilities/test-utils'

import * as alert from 'utilities/alert'
const errorSpy = jest.spyOn(alert, 'error')

const appPlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const products = [
  { id: 0, name: 'API 0', systemName: 'api-0', description: '', updatedAt: '', appPlans, servicePlans: [], defaultServicePlan: null, defaultAppPlan: null },
  { id: 1, name: 'API 1', systemName: 'api-1', description: '', updatedAt: '', appPlans, servicePlans: [], defaultServicePlan: null, defaultAppPlan: null }
]
const buyers = [
  { id: 0, name: 'Buyer 0', admin: '', createdAt: '', contractedProducts: [], createApplicationPath: '/buyers/0/applications/new' },
  { id: 1, name: 'Buyer 1', admin: '', createdAt: '', contractedProducts: [], createApplicationPath: '/buyers/1/applications/new' }
]
const defaultProps = {
  createApplicationPath: '/applications/new',
  createApplicationPlanPath: '/accounts/applications/new',
  serviceSubscriptionsPath: '/foo',
  createServicePlanPath: '/bar',
  product: undefined,
  products: undefined,
  productsCount: undefined,
  servicePlansAllowed: undefined,
  buyer: undefined,
  buyers: undefined,
  buyersCount: undefined,
  definedFields: undefined,
  validationErrors: {},
  error: undefined
}

const mountWrapper = (props) => mount(<NewApplicationForm {...{...defaultProps, ...props}}/>)
const renderWrapper = (props) => render(<NewApplicationForm {...{...defaultProps, ...props}}/>)

const select = (wrapper, from: string, obj: { name: string }) => {
  const toggle = wrapper.find(`${from} .pf-c-select__toggle-button`)
  if (toggle.props().disabled) {
    throw new Error('the select is disabled')
  }
  toggle.simulate('click')
  const item = wrapper.find(`${from} button`).findWhere(n => n.text() === obj.name).at(0)
  if (!item.exists()) {
    throw new Error('the item does not exist in the select')
  }
  item.simulate('click')
  wrapper.update()
}

const selectBuyer = (wrapper, buyer) => select(wrapper, 'BuyerSelect', buyer)
const selectProduct = (wrapper, product) => select(wrapper, 'ProductSelect', product)
const selectApplicationPlan = (wrapper, plan) => select(wrapper, 'ApplicationPlanSelect', plan)
const selectServicePlan = (wrapper, plan) => select(wrapper, 'ServicePlanSelect', plan)

describe('when in Service context', () => {
  let props
  const servicePlan = { id: 0, name: 'Service Plan' }
  const currentProduct = {
    id: 10,
    name: 'Current Product',
    updatedAt: '',
    appPlans,
    servicePlans: [servicePlan],
    defaultServicePlan: null,
    defaultAppPlan: null,
    systemName: 'current_api'
  }

  beforeEach(() => {
    props = { ...defaultProps, buyers, product: currentProduct }
  })

  describe('when product has no application plans', () => {
    const productWithNoAppPlans = { ...currentProduct, appPlans: [] }

    beforeEach(() => {
      props.product = productWithNoAppPlans
    })

    it('should render a link to create an application plan', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find(`ApplicationPlanSelect .hint a[href="${props.createApplicationPlanPath}"]`).exists()).toBe(true)
    })

    it('should disable the application plan select', () => {
      const wrapper = mountWrapper(props)
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()
      expect(isDisabled()).toBe(true)
    })

    it('should not be able to submit', () => {
      const wrapper = mountWrapper(props)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      expect(() => selectApplicationPlan(wrapper, appPlans[0])).toThrowError('the select is disabled')
      expect(isSubmitDisabled(wrapper)).toBe(true)
    })
  })

  describe('when product has application plans', () => {
    const productWithAppPlans = { ...currentProduct, appPlans }

    beforeEach(() => {
      props.product = productWithAppPlans
    })

    it('should not render a link to create an application plan', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find(`ApplicationPlanSelect .hint a[href="${defaultProps.createApplicationPlanPath}"]`).exists()).toBe(false)
    })

    it('should enable the application plan select', () => {
      const wrapper = mountWrapper(props)
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()
      expect(isDisabled()).toBe(false)
    })

    it('should be able to submit only when form is complete', () => {
      const wrapper = mountWrapper(props)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectBuyer(wrapper, buyers[0])
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, productWithAppPlans.appPlans[0])
      expect(isSubmitDisabled(wrapper)).toBe(false)
    })

    describe('and it has a default application plan', () => {
      const defaultAppPlan = productWithAppPlans.appPlans[0]
      const productWithDefaultAppPlan = { ...productWithAppPlans, defaultAppPlan }

      beforeEach(() => {
        props.product = productWithDefaultAppPlan
      })

      it('should have the default plan selected', () => {
        const wrapper = mountWrapper(props)
        selectBuyer(wrapper, buyers[0])

        expect(wrapper.find('ApplicationPlanSelect').props().appPlan).toBe(defaultAppPlan)
      })

      it('should not need to select a plan to submit', () => {
        const wrapper = mountWrapper(props)
        expect(isSubmitDisabled(wrapper)).toBe(true)

        selectBuyer(wrapper, buyers[0])

        expect(isSubmitDisabled(wrapper)).toBe(false)
      })
    })

    describe('but it has no default application plan', () => {
      const productWithNoDefaultAppPlan = { ...productWithAppPlans, defaultAppPlan: null }

      beforeEach(() => {
        props.product = productWithNoDefaultAppPlan
      })

      it('should have no default plan selected', () => {
        const wrapper = mountWrapper(props)
        expect(wrapper.find('ApplicationPlanSelect').props().appPlan).toBe(null)
      })
    })
  })

  it('should show an alert if there is an error', () => {
    const error = 'Something went wrong'
    mountWrapper({ ...props, error })

    expect(errorSpy).toHaveBeenCalledWith(error)
  })

  describe('when service plans are allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = true
    })

    it('should render buyer, app plan and service plan selects', () => {
      const inputs = [
        'account_id',
        'cinstance_service_plan_id',
        'cinstance_plan_id'
      ]
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
      expect(html).not.toMatch('>Product</span>')
    })

    describe('when the selected buyer is subscribed to the current product', () => {
      const buyerSubscribed = {
        id: 10,
        name: 'Buyer 10',
        admin: '',
        createdAt: '',
        contractedProducts: [{ id: currentProduct.id, name: currentProduct.name, withPlan: servicePlan }],
        createApplicationPath: '/buyers/0/applications/new'
      }

      beforeEach(() => {
        props.buyers = [buyerSubscribed]
      })

      it('should have a service plan selected', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, buyerSubscribed)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toEqual(servicePlan)
        expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
      })

      it('should not be able to change the service plan', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, buyerSubscribed)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
      })

      it('should display a clarification why service plan is disabled and a link to change it', () => {
        const wrapper = mountWrapper(props)
        selectBuyer(wrapper, buyerSubscribed)

        const hints = wrapper.find('.hint')
        expect(hints.length).toBe(1)
        expect(hints.at(0).text()).toMatch('This account already subscribes to the service plan of the selected product. To change the account to subscribe to a different service plan for this product, go to Service subscriptions.')
        expect(hints.find('a').prop('href')).toEqual(props.serviceSubscriptionsPath)
      })
    })

    describe('when the buyer is not subscribed to the current product', () => {
      const buyerNotSubscribed = {
        id: 10,
        name: 'Buyer 10',
        admin: '',
        createdAt: '',
        contractedProducts: [],
        createApplicationPath: '/buyers/0/applications/new'
      }

      beforeEach(() => {
        props.buyers = [buyerNotSubscribed]
      })

      it('should show a hint for service plan select', () => {
        const wrapper = mountWrapper(props)
        selectBuyer(wrapper, buyerNotSubscribed)

        const hints = wrapper.find('ServicePlanSelect .hint')
        expect(hints.length).toBe(1)
        expect(hints.text()).toMatch('To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product.')
      })

      describe('when the current product has no service plans', () => {
        beforeEach(() => {
          props.product = { ...currentProduct, servicePlans: [] }
        })

        it('should not have a service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBeNull()
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(false)
        })

        it('should display a link to create a new service plan', () => {
          const wrapper = mountWrapper(props)
          selectBuyer(wrapper, buyerNotSubscribed)

          const hints = wrapper.find('.hint')
          expect(hints.length).toBe(2)
          expect(hints.at(1).text()).toMatch('No service plans exist for the selected product. Create a new service plan')
          expect(hints.find('a').prop('href')).toEqual(props.createServicePlanPath)
        })
      })

      describe('when the current product has service plans and one is default', () => {
        const defaultServicePlan = { id: 100, name: 'Other plan (default)' }
        const servicePlans = [
          { id: 0, name: 'First plan (not default)' },
          defaultServicePlan
        ]

        beforeEach(() => {
          props.product = { ...currentProduct, servicePlans, defaultServicePlan }
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
        })

        it('should have the default service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(defaultServicePlan)
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })
      })

      describe('when the current product has service plans but none is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (not default)' }
        ]
        const productWithNoDefaultPlan = { ...currentProduct, servicePlans, defaultServicePlan: null }

        beforeEach(() => {
          props.product = productWithNoDefaultPlan
        })

        it.todo('should have the first service plan selected')

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
          selectServicePlan(wrapper, servicePlans[1])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[1])
        })
      })
    })
  })

  describe('when service plans are not allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = false
    })

    it('should render buyer and app plan selects', () => {
      const inputs = [
        'account_id',
        'cinstance_plan_id'
      ]
      const not = [
        'product',
        'cinstance_service_plan_id'
      ]
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
      not.forEach(name => expect(html).not.toMatch(name))
    })
  })
})

describe('when in Account context', () => {
  let props
  const currentBuyer = {
    id: 0,
    name: 'Mr. Buyer',
    admin: '',
    description: '',
    createdAt: '',
    contractedProducts: [],
    createApplicationPath: '/account/0/applications/new'
  }

  beforeEach(() => {
    props = { ...defaultProps, products, buyer: currentBuyer }
  })

  describe('when selected product has no application plans defined', () => {
    const productWithNoAppPlans = { ...products[0], appPlans: [] }

    it('should render a link to create an application plan', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithNoAppPlans] })
      const findHint = () => wrapper.find(`ApplicationPlanSelect .hint a[href="${defaultProps.createApplicationPlanPath}"]`).exists()
      expect(findHint()).toBe(false)
      selectProduct(wrapper, productWithNoAppPlans)
      expect(findHint()).toBe(true)
    })

    it('should disable the application plan select', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithNoAppPlans] })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectProduct(wrapper, productWithNoAppPlans)
      expect(isDisabled()).toBe(true)
    })

    it('should not be able to submit', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithNoAppPlans] })
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, productWithNoAppPlans)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      expect(() => selectApplicationPlan(wrapper, appPlans[0])).toThrowError('the select is disabled')
      expect(isSubmitDisabled(wrapper)).toBe(true)
    })
  })

  describe('when selected product has application plans', () => {
    const productWithAppPlans = { ...products[0], appPlans }

    it('should not render a link to create an application plan', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithAppPlans] })
      const findHint = () => wrapper.find(`ApplicationPlanSelect .hint a[href="${defaultProps.createApplicationPlanPath}"]`).exists()
      expect(findHint()).toBe(false)
      selectProduct(wrapper, productWithAppPlans)
      expect(findHint()).toBe(false)
    })

    it('should enable the application plan select', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithAppPlans] })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectProduct(wrapper, productWithAppPlans)
      expect(isDisabled()).toBe(false)
    })

    it('should be able to submit only when form is complete', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithAppPlans] })
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, productWithAppPlans)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, productWithAppPlans.appPlans[0])
      expect(isSubmitDisabled(wrapper)).toBe(false)
    })

    describe('and it has a default application plan', () => {
      const defaultAppPlan = appPlans[0]
      const productWithDefaultAppPlan = { ...productWithAppPlans, defaultAppPlan }

      it('should have the default plan selected', () => {
        const wrapper = mountWrapper({ ...props, products: [productWithDefaultAppPlan] })
        selectProduct(wrapper, productWithAppPlans)

        expect(wrapper.find('ApplicationPlanSelect').props().appPlan).toEqual(defaultAppPlan)
      })

      it('should not need to select a plan to submit', () => {
        const wrapper = mountWrapper({ ...props, products: [productWithDefaultAppPlan] })
        expect(isSubmitDisabled(wrapper)).toBe(true)

        selectProduct(wrapper, productWithAppPlans)
        expect(isSubmitDisabled(wrapper)).toBe(false)
      })
    })

    describe('but it has no default application plan', () => {
      const productWithNoDefaultAppPlan = { ...productWithAppPlans, defaultAppPlan: null }

      it('should have no plan selected by default', () => {
        const wrapper = mountWrapper({ ...props, products: [productWithNoDefaultAppPlan] })
        selectProduct(wrapper, productWithAppPlans)

        expect(wrapper.find('ApplicationPlanSelect').props().appPlan).toEqual(null)
      })
    })
  })

  it('should show an alert if there is an error', () => {
    const error = 'Something went wrong'
    mountWrapper({ ...props, error })

    expect(errorSpy).toHaveBeenCalledWith(error)
  })

  describe('when service plans are not allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = false
    })

    it('should render product and app plan selects', () => {
      const inputs = [
        'product',
        'cinstance_plan_id'
      ]
      const not = [
        'account_id',
        'cinstance_service_plan_id'
      ]
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
      not.forEach(name => expect(html).not.toMatch(name))
    })

    it('should enable submit button without a service plan being selected', () => {
      const wrapper = mountWrapper(props)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, products[0])
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, appPlans[0])
      expect(isSubmitDisabled(wrapper)).toBe(false)
    })
  })

  describe('when service plans are allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = true
    })

    it('should render product, app plan and service plan selects', () => {
      const inputs = [
        'product',
        'cinstance_service_plan_id',
        'cinstance_plan_id'
      ]
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
      expect(html).not.toMatch('account_id')
    })

    it.todo('should not show a service plan hints if a product is not yet selected?')

    describe('when the current buyer is subscribed to the selected product', () => {
      const servicePlan = { id: 0, name: 'Service plan' }
      const [id, name] = [33, 'Subscribed API']
      const subscribedProduct = { ...products[0], id, name, servicePlans: [servicePlan] }

      beforeEach(() => {
        props.buyer = { ...currentBuyer, contractedProducts: [{ id, name, withPlan: servicePlan }] }
        props.products = [subscribedProduct]
      })

      it('should have a service plan selected', () => {
        const wrapper = mountWrapper(props)

        selectProduct(wrapper, subscribedProduct)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toEqual(servicePlan)
        expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
      })

      it('should not be able to change the service plan', () => {
        const wrapper = mountWrapper(props)

        selectProduct(wrapper, subscribedProduct)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
      })

      it('should display a clarification why service plan is disabled and a link to change it', () => {
        const wrapper = mountWrapper(props)
        selectProduct(wrapper, subscribedProduct)

        const hints = wrapper.find('.hint')
        expect(hints.length).toBe(1)
        expect(hints.at(0).text()).toMatch('This account already subscribes to the service plan of the selected product. To change the account to subscribe to a different service plan for this product, go to Service subscriptions.')
        expect(hints.find('a').prop('href')).toEqual(props.serviceSubscriptionsPath)
      })
    })

    describe('when the current buyer is not subscribed to the selected product', () => {
      beforeEach(() => {
        props.buyer = { ...currentBuyer, contractedProducts: [] }
      })

      it('should show a hint for service plan select', () => {
        const wrapper = mountWrapper(props)
        const hints = wrapper.find('ServicePlanSelect .hint')
        expect(hints.length).toBe(1)
        expect(hints.text()).toMatch('To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product.')
      })

      describe('when it has no service plans', () => {
        const productWithNoPlans = { ...products[0], servicePlans: [] }

        beforeEach(() => {
          props.products = [productWithNoPlans]
        })

        it('should not have a service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, productWithNoPlans)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBeNull()
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(false)
        })

        it('should display a link to create a new service plan', () => {
          const wrapper = mountWrapper(props)
          selectProduct(wrapper, productWithNoPlans)

          const hints = wrapper.find('.hint')
          expect(hints.length).toBe(2)
          expect(hints.at(1).text()).toMatch('No service plans exist for the selected product. Create a new service plan')
          expect(hints.find('a').prop('href')).toEqual(props.createServicePlanPath)
        })
      })

      describe('when it has service plans and one is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (default)' }
        ]
        const defaultServicePlan = servicePlans[1]
        const productWithDefaultPlan = { ...products[0], servicePlans, defaultServicePlan }

        beforeEach(() => {
          props.products = [productWithDefaultPlan]
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, productWithDefaultPlan)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
        })

        it('should have the default service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, productWithDefaultPlan)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(defaultServicePlan)
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)

          selectServicePlan(wrapper, servicePlans[0])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).not.toBe(defaultServicePlan)
        })
      })

      describe('when it has service plans but none is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan' },
          { id: 1, name: 'Second Plan' }
        ]
        const productWithNoDefaultPlan = { ...products[0], servicePlans, defaultServicePlan: null }

        beforeEach(() => {
          props.products = [productWithNoDefaultPlan]
        })

        it.todo('should have the first service plan selected')

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, productWithNoDefaultPlan)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
          selectServicePlan(wrapper, servicePlans[1])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[1])
        })
      })
    })
  })

  describe('when there are extra fields', () => {
    const definedFields = [
      { hidden: false, readOnly: false, required: true, label: 'Name', name: 'name', id: 'name', type: 'builtin' },
      { hidden: false, readOnly: false, required: true, label: 'State', name: 'state', id: 'state', choices: ['active', 'pending'], type: 'builtin' }
    ]

    beforeEach(() => {
      props.definedFields = definedFields
    })

    it('should render all inputs', () => {
      const inputs = definedFields.map(field => field.name)
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
    })

    it('should be able to submit only when form is complete', () => {
      const wrapper = mountWrapper(props)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, products[0])
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, appPlans[0])
      expect(isSubmitDisabled(wrapper)).toBe(true)

      act(() => wrapper.find('UserDefinedField').at(0).props().onChange('My Name'))
      wrapper.update()
      expect(isSubmitDisabled(wrapper)).toBe(true)

      act(() => wrapper.find('UserDefinedField').at(1).props().onChange('active'))
      wrapper.update()
      expect(isSubmitDisabled(wrapper)).toBe(false)
    })
  })
})

describe('when in Audience context', () => {
  let props

  beforeEach(() => {
    props = { ...defaultProps, buyers, products }
  })

  it('should be able to submit only when form is complete', () => {
    const wrapper = mountWrapper(props)
    expect(isSubmitDisabled(wrapper)).toBe(true)

    selectBuyer(wrapper, buyers[0])
    expect(isSubmitDisabled(wrapper)).toBe(true)

    selectProduct(wrapper, products[0])
    expect(isSubmitDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isSubmitDisabled(wrapper)).toBe(false)
  })

  describe('when selected product has application plans', () => {
    const productWithAppPlans = { ...products[0], appPlans }

    beforeEach(() => {
      props.products = [productWithAppPlans]
    })

    it('should enable the Application plan select', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithAppPlans] })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectBuyer(wrapper, buyers[0])
      expect(isDisabled()).toBe(true)

      selectProduct(wrapper, productWithAppPlans)
      expect(isDisabled()).toBe(false)
    })

    it('should be able to submit only when form is complete', () => {
      const wrapper = mountWrapper(props)
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectBuyer(wrapper, buyers[0])
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, products[0])
      expect(isSubmitDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, appPlans[0])
      expect(isSubmitDisabled(wrapper)).toBe(false)
    })

    describe('and it has a default application plan', () => {
      const defaultAppPlan = appPlans[0]
      const productWithDefaultPlan = { ...productWithAppPlans, defaultAppPlan }

      it('should have the default plan selected', () => {
        const wrapper = mountWrapper({ ...props, products: [productWithDefaultPlan] })
        selectBuyer(wrapper, buyers[0])
        selectProduct(wrapper, productWithDefaultPlan)

        expect(wrapper.find('ApplicationPlanSelect').props().appPlan).toBe(defaultAppPlan)
      })

      it('should not need to select a plan to submit', () => {
        const wrapper = mountWrapper({ ...props, products: [productWithDefaultPlan] })
        expect(isSubmitDisabled(wrapper)).toBe(true)

        selectBuyer(wrapper, buyers[0])
        selectProduct(wrapper, productWithDefaultPlan)

        expect(isSubmitDisabled(wrapper)).toBe(false)
      })
    })

    describe('but it does not have a default application plan', () => {
      const productNoDefaultPlan = { ...productWithAppPlans, defaultAppPlan: null }

      it('should have no plan selected', () => {
        const wrapper = mountWrapper({ ...props, products: [productNoDefaultPlan] })
        expect(wrapper.find('ApplicationPlanSelect').props().appPlan).toBe(null)
      })
    })
  })

  describe('when selected product has no application plans', () => {
    const productWithNoAppPlans = { ...products[0], appPlans: [] }

    beforeEach(() => {
      props.products = [productWithNoAppPlans]
    })

    it('should disable the Application plan select', () => {
      const wrapper = mountWrapper({ ...props, products: [productWithNoAppPlans] })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectBuyer(wrapper, buyers[0])
      expect(isDisabled()).toBe(true)

      selectProduct(wrapper, productWithNoAppPlans)
      expect(isDisabled()).toBe(true)
    })
  })

  describe('when service plans are not allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = false
    })

    it('should render buyer, product and app plan selects', () => {
      const inputs = [
        'account_id',
        'product',
        'cinstance_plan_id'
      ]
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
      expect(html).not.toMatch('cinstance_service_plan_id')
    })
  })

  describe('when service plans are allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = true
    })

    it('should render all selects', () => {
      const inputs = [
        'account_id',
        'product',
        'cinstance_plan_id',
        'cinstance_service_plan_id'
      ]
      const html = renderWrapper(props).find('.pf-c-form__group').toString()

      inputs.forEach(name => expect(html).toMatch(name))
    })

    describe('when the selected buyer is subscribed to the selected product', () => {
      const servicePlan = { id: 0, name: 'Service Plan' }
      const [id, name] = [12, 'Subscribed API']
      const contractedProduct = { ...products[0], id, name, servicePlans: [servicePlan] }
      const subscribedBuyer = { ...buyers[0], contractedProducts: [{ id, name: name, withPlan: servicePlan }] }

      beforeEach(() => {
        props.buyers = [subscribedBuyer]
        props.products = [contractedProduct]
      })

      it('should have a service plan selected', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, subscribedBuyer)
        selectProduct(wrapper, contractedProduct)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toEqual(servicePlan)
        expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
      })

      it('should not be able to change the service plan', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, subscribedBuyer)
        selectProduct(wrapper, contractedProduct)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
      })

      it('should display a clarification why service plan is disabled and a link to change it', () => {
        const wrapper = mountWrapper(props)
        selectBuyer(wrapper, subscribedBuyer)
        selectProduct(wrapper, contractedProduct)

        const hints = wrapper.find('.hint')
        expect(hints.length).toBe(1)
        expect(hints.at(0).text()).toMatch('This account already subscribes to the service plan of the selected product. To change the account to subscribe to a different service plan for this product, go to Service subscriptions.')
        expect(hints.find('a').prop('href')).toEqual(props.serviceSubscriptionsPath)
      })
    })

    describe('when the selected buyer is not subscribed to the selected product', () => {
      const buyerNotSubscribed = { ...buyers[0], contractedProducts: [] }

      beforeEach(() => {
        props.buyers = [buyerNotSubscribed]
      })

      describe('when it has no service plans', () => {
        const productWithNoPlans = { ...products[0], servicePlans: [] }

        beforeEach(() => {
          props.products = [productWithNoPlans]
        })

        it('should not have a service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)
          selectProduct(wrapper, productWithNoPlans)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBeNull()
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(false)
        })

        it('should display a link to create a new service plan', () => {
          const wrapper = mountWrapper(props)
          selectBuyer(wrapper, buyerNotSubscribed)
          selectProduct(wrapper, productWithNoPlans)

          const hints = wrapper.find('.hint')
          expect(hints.length).toBe(2)
          expect(hints.at(1).text()).toMatch('No service plans exist for the selected product. Create a new service plan')
          expect(hints.find('a').prop('href')).toEqual(props.createServicePlanPath)
        })
      })

      describe('when it has service plans and one is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (default)' }
        ]
        const defaultServicePlan = servicePlans[1]
        const productWithDefaultPlan = { ...products[0], servicePlans, defaultServicePlan }

        beforeEach(() => {
          props.products = [productWithDefaultPlan]
        })

        it('should have the default service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyers[0])
          selectProduct(wrapper, productWithDefaultPlan)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(defaultServicePlan)
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyers[0])
          selectProduct(wrapper, productWithDefaultPlan)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(defaultServicePlan)
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)

          selectServicePlan(wrapper, servicePlans[0])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).not.toBe(defaultServicePlan)
        })

        it('should show a hint for service plan select', () => {
          const wrapper = mountWrapper(props)
          selectBuyer(wrapper, buyerNotSubscribed)
          selectProduct(wrapper, productWithDefaultPlan)

          const hints = wrapper.find('ServicePlanSelect .hint')
          expect(hints.length).toBe(1)
          expect(hints.text()).toMatch('To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product.')
        })
      })

      describe('when the selected product has service plans but none is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (not default)' }
        ]
        const productWithNoDefaultPlan = { ...products[0], servicePlans, defaultServicePlan: null }

        beforeEach(() => {
          props.products = [productWithNoDefaultPlan]
        })

        it.todo('should have the first service plan selected')

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyers[0])
          selectProduct(wrapper, productWithNoDefaultPlan)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
          selectServicePlan(wrapper, servicePlans[1])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[1])
        })

        it('should show a hint for service plan select', () => {
          const wrapper = mountWrapper(props)
          selectBuyer(wrapper, buyerNotSubscribed)
          selectProduct(wrapper, productWithNoDefaultPlan)

          const hints = wrapper.find('ServicePlanSelect .hint')
          expect(hints.length).toBe(1)
          expect(hints.text()).toMatch('To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product.')
        })
      })
    })
  })
})
