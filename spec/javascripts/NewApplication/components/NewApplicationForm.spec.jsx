// @flow

import React from 'react'

import { act } from 'react-dom/test-utils'
import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'NewApplication/components/NewApplicationForm'

import * as alert from 'utilities/alert'
const errorSpy = jest.spyOn(alert, 'error')

const appPlans = [{ id: 0, name: 'Basic Plan', issuer_id: 0, default: false }]
const products = [
  { id: '0', name: 'API 0', systemName: 'api-0', description: '', updatedAt: '', appPlans, servicePlans: [], defaultServicePlan: null },
  { id: '1', name: 'API 1', systemName: 'api-1', description: '', updatedAt: '', appPlans, servicePlans: [], defaultServicePlan: null }
]
const buyers = [
  { id: '0', name: 'Buyer 0', admin: '', createdAt: '', contractedProducts: [], createApplicationPath: '/buyers/0/applications/new' },
  { id: '1', name: 'Buyer 1', admin: '', createdAt: '', contractedProducts: [], createApplicationPath: '/buyers/1/applications/new' }
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

const isButtonDisabled = (wrapper) => wrapper.update().find('button[type="submit"]').prop('disabled')

const select = (wrapper, from: string, obj: { name: string }) => {
  wrapper.find(`${from} .pf-c-select__toggle-button`).simulate('click')
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
    id: '10',
    name: 'Current Product',
    description: '',
    updatedAt: '',
    appPlans,
    servicePlans: [servicePlan],
    defaultServicePlan: null,
    systemName: 'current_api'
  }

  beforeEach(() => {
    props = { ...defaultProps, buyers, product: currentProduct }
  })

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
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectBuyer(wrapper, buyers[0])
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isButtonDisabled(wrapper)).toBe(false)
  })

  describe('when service plans are allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = true
    })

    describe('when the selected buyer is subscribed to the current product', () => {
      const buyerSubscribed = {
        id: '10',
        name: 'Buyer 10',
        admin: '',
        createdAt: '',
        contractedProducts: [{ id: Number(currentProduct.id), name: currentProduct.name, withPlan: servicePlan }],
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
    })

    describe('when the buyer is not subscribed to the current product', () => {
      const buyerNotSubscribed = {
        id: '10',
        name: 'Buyer 10',
        admin: '',
        createdAt: '',
        contractedProducts: [],
        createApplicationPath: '/buyers/0/applications/new'
      }

      beforeEach(() => {
        props.buyers = [buyerNotSubscribed]
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

        it('should hint the user to create a service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)

          expect(wrapper.find('ServicePlanSelect .hint')).toMatchSnapshot()
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
})

describe('when in Account context', () => {
  let props
  const currentBuyer = {
    id: '0',
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
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectProduct(wrapper, products[0])
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isButtonDisabled(wrapper)).toBe(false)
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
  })

  describe('when product allows changing the Application plan', () => {
    const productCanChangePlan = { ...products[0], buyerCanSelectPlan: true }

    it('should enable the Application plan select', () => {
      const wrapper = mountWrapper({ ...props, products: [productCanChangePlan] })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectProduct(wrapper, productCanChangePlan)
      expect(isDisabled()).toBe(false)
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

    it('should not render a select for service plans', () => {
      const html = renderWrapper(props).find('.pf-c-form__group').toString()
      expect(html).not.toMatch('cinstance_service_plan_id')
    })

    it('should enable submit button without a service plan being selected', () => {
      const wrapper = mountWrapper(props)
      expect(isButtonDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, products[0])
      expect(isButtonDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, appPlans[0])
      expect(isButtonDisabled(wrapper)).toBe(false)
    })
  })

  describe('when service plans are allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = true
    })

    it('should render a select for service plans', () => {
      const html = renderWrapper(props).find('.pf-c-form__group').toString()
      expect(html).toMatch('cinstance_service_plan_id')
    })

    describe('when the current buyer is subscribed to the selected product', () => {
      const servicePlan = { id: 0, name: 'Service plan' }
      const [id, name] = ['33', 'Subscribed API']
      const subscribedProduct = { ...products[0], id, name, servicePlans: [servicePlan] }

      beforeEach(() => {
        props.buyer = { ...currentBuyer, contractedProducts: [{ id: Number(id), name, withPlan: servicePlan }] }
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
    })

    describe('when the current buyer is not subscribed to the selected product', () => {
      beforeEach(() => {
        props.buyer = { ...currentBuyer, contractedProducts: [] }
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

        it('should hint the user to create a service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, productWithNoPlans)

          expect(wrapper.find('ServicePlanSelect .hint')).toMatchSnapshot()
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
      expect(isButtonDisabled(wrapper)).toBe(true)

      selectProduct(wrapper, products[0])
      expect(isButtonDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, appPlans[0])
      expect(isButtonDisabled(wrapper)).toBe(true)

      act(() => wrapper.find('UserDefinedField').at(0).props().onChange('My Name'))
      wrapper.update()
      expect(isButtonDisabled(wrapper)).toBe(true)

      act(() => wrapper.find('UserDefinedField').at(1).props().onChange('active'))
      wrapper.update()
      expect(isButtonDisabled(wrapper)).toBe(false)
    })
  })
})

describe('when in Audience context', () => {
  let props

  beforeEach(() => {
    props = { ...defaultProps, buyers, products }
  })

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
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectBuyer(wrapper, buyers[0])
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectProduct(wrapper, products[0])
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isButtonDisabled(wrapper)).toBe(false)
  })

  describe('when service plans are allowed', () => {
    beforeEach(() => {
      props.servicePlansAllowed = true
    })

    describe('when the selected buyer is subscribed to the selected product', () => {
      const servicePlan = { id: 0, name: 'Service Plan' }
      const [id, name] = ['12', 'Subscribed API']
      const contractedProduct = { ...products[0], id, name, servicePlans: [servicePlan] }
      const subscribedBuyer = { ...buyers[0], contractedProducts: [{ id: Number(id), name: name, withPlan: servicePlan }] }

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

        it('should hint the user to create a service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, buyerNotSubscribed)
          selectProduct(wrapper, productWithNoPlans)

          expect(wrapper.find('ServicePlanSelect .hint')).toMatchSnapshot()
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
      })
    })
  })
})
