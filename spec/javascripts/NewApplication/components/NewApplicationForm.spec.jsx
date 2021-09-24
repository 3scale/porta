// @flow

import React from 'react'

import { act } from 'react-dom/test-utils'
import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'NewApplication/components/NewApplicationForm'

import * as alert from 'utilities/alert'
const errorSpy = jest.spyOn(alert, 'error')

const servicePlans = [{ id: 0, name: 'Service plan' }]
const appPlans = [{ id: 0, name: 'Basic Plan' }]
const products = [
  { id: '0', name: 'API Product', description: '', updatedAt: '', appPlans, servicePlans: [] },
  { id: '1', name: 'API w/o plans', description: '', updatedAt: '', appPlans, servicePlans: [] }
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
  mostRecentlyUpdatedProducts: undefined,
  productsCount: undefined,
  servicePlansAllowed: undefined,
  buyer: undefined,
  mostRecentlyCreatedBuyers: undefined,
  buyersCount: undefined,
  definedFields: undefined,
  validationErrors: {},
  error: undefined
}

const mountWrapper = (props) => mount(<NewApplicationForm {...{...defaultProps, ...props}}/>)
const renderWrapper = (props) => render(<NewApplicationForm {...{...defaultProps, ...props}}/>)

const isButtonDisabled = (wrapper) => wrapper.update().find('button[type="submit"]').prop('disabled')

const selectBuyer = (wrapper, buyer) => {
  act(() => wrapper.find('BuyerSelect').props().onSelectBuyer(buyer))
  wrapper.update()
}

const selectProduct = (wrapper, product) => {
  act(() => wrapper.find('ProductSelect').props().onSelectProduct(product))
  wrapper.update()
}

const selectApplicationPlan = (wrapper, plan) => {
  act(() => wrapper.find('ApplicationPlanSelect').props().onSelect(plan))
  wrapper.update()
}

const selectServicePlan = (wrapper, plan) => {
  act(() => wrapper.find('ServicePlanSelect').props().onSelect(plan))
  wrapper.update()
}

describe('when in Service context', () => {
  const servicePlan = { id: 0, name: 'Service Plan' }
  const currentProduct = { id: '10', name: 'Current Product', description: '', updatedAt: '', appPlans, servicePlans: [servicePlan] }
  const props = {
    ...defaultProps,
    mostRecentlyCreatedBuyers: buyers,
    product: currentProduct
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
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectBuyer(wrapper, buyer)
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isButtonDisabled(wrapper)).toBe(false)
  })

  describe('when service plans are allowed', () => {
    beforeAll(() => {
      props.servicePlansAllowed = true
    })

    describe('when the selected buyer is subscribed to the current product', () => {
      const selectedBuyer = { ...buyer, contractedProducts: [{ id: Number(currentProduct.id), name: currentProduct.name, withPlan: servicePlan }] }

      beforeAll(() => {
        props.mostRecentlyCreatedBuyers = [selectedBuyer]
      })

      it('should have a service plan selected', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, selectedBuyer)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toEqual(servicePlan)
        expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
      })

      it('should not be able to change the service plan', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, selectedBuyer)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
      })
    })

    describe('when the buyer is not subscribed to the current product', () => {
      const selectedBuyer = { ...buyer, contractedProducts: [] }

      beforeAll(() => {
        props.mostRecentlyCreatedBuyers = [selectedBuyer]
      })

      describe('when the current product has no service plans', () => {
        beforeAll(() => {
          props.product = { ...currentProduct, servicePlans: [] }
        })

        it('should not be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
        })

        it('should not have a service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBeNull()
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(false)
        })

        it('should hint the user to create a service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('ServicePlanSelect .hint')).toMatchSnapshot()
        })
      })

      describe('when the current product has service plans and one is default', () => {
        const defaultServicePlan = { id: 100, name: 'Other plan (default)' }
        const servicePlans = [
          { id: 0, name: 'First plan (not default)' },
          defaultServicePlan
        ]

        beforeAll(() => {
          props.product = { ...currentProduct, servicePlans, defaultServicePlan }
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
        })

        it('should have the default service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(defaultServicePlan)
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })
      })

      describe('when the current product has service plans but none is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (not default)' }
        ]

        beforeAll(() => {
          props.product = { ...currentProduct, servicePlans, defaultServicePlan: undefined }
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
        })

        it('should have the first service plan, not the default one, selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[0])
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })
      })
    })
  })
})

describe('when in Account context', () => {
  const selectedProduct = { id: '0', name: 'My Product', description: '', updatedAt: '', appPlans, servicePlans }
  const currentBuyer = { id: '0', name: 'Mr. Buyer', description: '', createdAt: '', contractedProducts: [], createApplicationPath: '/account/0/applications/new' }
  const props = {
    ...defaultProps,
    buyer: currentBuyer,
    mostRecentlyUpdatedProducts: [selectedProduct]
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
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectProduct(wrapper, products[0])
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isButtonDisabled(wrapper)).toBe(false)
  })

  describe('when selected product has no application plans defined', () => {
    const productWithNoPlans = { id: '0', name: 'API w/o plans', description: '', updatedAt: '', appPlans: [], servicePlans: [] }
    const mostRecentlyUpdatedProducts = [productWithNoPlans]

    it('should render a link to create an application plan', () => {
      const wrapper = mountWrapper({ ...props, mostRecentlyUpdatedProducts })
      const findHint = () => wrapper.find(`ApplicationPlanSelect .hint a[href="${defaultProps.createApplicationPlanPath}"]`).exists()
      expect(findHint()).toBe(false)
      selectProduct(wrapper, productWithNoPlans)
      expect(findHint()).toBe(true)
    })
  })

  describe('when selected product has some application plans defined', () => {
    const product = { id: '0', name: 'API', description: '', updatedAt: '', appPlans, servicePlans: [] }
    const mostRecentlyUpdatedProducts = [product]

    it('should not render a link to create an application plan', () => {
      const wrapper = mountWrapper({ ...props, mostRecentlyUpdatedProducts })
      const findHint = () => wrapper.find(`ApplicationPlanSelect .hint a[href="${defaultProps.createApplicationPlanPath}"]`).exists()
      expect(findHint()).toBe(false)
      selectProduct(wrapper, product)
      expect(findHint()).toBe(false)
    })
  })

  describe('when product allows changing the Application plan', () => {
    const product = { id: '0', name: 'API', description: '', updatedAt: '', appPlans, servicePlans: [], buyerCanSelectPlan: true }
    const mostRecentlyUpdatedProducts = [product]

    it('should enable the Application plan select', () => {
      const wrapper = mountWrapper({ ...props, mostRecentlyUpdatedProducts })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectProduct(wrapper, product)
      expect(isDisabled()).toBe(false)
    })
  })

  describe('when product does not allow changing the Application plan', () => {
    const product = { id: '0', name: 'API', description: '', updatedAt: '', appPlans, servicePlans: [], buyerCanSelectPlan: false }
    const mostRecentlyUpdatedProducts = [product]

    it('should disable the Application plan select', () => {
      const wrapper = mountWrapper({ ...props, mostRecentlyUpdatedProducts })
      const isDisabled = () => wrapper.find('ApplicationPlanSelect .pf-c-select .pf-m-disabled').exists()

      selectProduct(wrapper, product)
      expect(isDisabled()).toBe(true)
    })
  })

  it('should show an alert if there is an error', () => {
    const error = 'Something went wrong'
    mountWrapper({ ...props, error })

    expect(errorSpy).toHaveBeenCalledWith(error)
  })

  describe('when service plans are not allowed', () => {
    beforeAll(() => {
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
    beforeAll(() => {
      props.servicePlansAllowed = true
    })

    it('should render a select for service plans', () => {
      const html = renderWrapper(props).find('.pf-c-form__group').toString()
      expect(html).toMatch('cinstance_service_plan_id')
    })

    describe('when the current buyer is subscribed to the selected product', () => {
      const servicePlan = { id: 0, name: 'Service plan' }
      const subscribedProduct = { ...selectedProduct, servicePlans: [servicePlan] }
      const { id, name } = subscribedProduct

      beforeAll(() => {
        props.buyer = { ...currentBuyer, contractedProducts: [{ id: Number(id), name, withPlan: servicePlan }] }
        props.mostRecentlyUpdatedProducts = [subscribedProduct]
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
      beforeAll(() => {
        props.buyer = { ...currentBuyer, contractedProducts: [] }
      })

      describe('when it has no service plans', () => {
        const product = { id: '10', name: 'Selected API', description: '', updatedAt: '', appPlans, servicePlans: [] }

        beforeAll(() => {
          props.mostRecentlyUpdatedProducts = [product]
        })

        it('should not be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
        })

        it('should not have a service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBeNull()
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(false)
        })

        it('should hint the user to create a service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)

          expect(wrapper.find('ServicePlanSelect .hint')).toMatchSnapshot()
        })
      })

      describe('when it has service plans and one is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (default)' }
        ]
        const defaultServicePlan = servicePlans[1]
        const product = { id: '10', name: 'Selected API', description: '', updatedAt: '', appPlans, servicePlans, defaultServicePlan }

        beforeAll(() => {
          props.mostRecentlyUpdatedProducts = [product]
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)
        })

        it('should have the default service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)

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
        const product = { id: '10', name: 'Selected API', description: '', updatedAt: '', appPlans, servicePlans, defaultServicePlan: undefined }

        beforeAll(() => {
          props.mostRecentlyUpdatedProducts = [product]
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[0])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)

          selectServicePlan(wrapper, servicePlans[1])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[1])
        })

        it('should select the first Service plan by default', () => {
          const wrapper = mountWrapper(props)

          selectProduct(wrapper, product)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[0])
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })
      })
    })
  })

  describe('when there are extra fields', () => {
    const definedFields = [
      { hidden: false, readOnly: false, required: true, label: 'Name', name: 'name', id: 'name', type: 'builtin' },
      { hidden: false, readOnly: false, required: true, label: 'State', name: 'state', id: 'state', choices: ['active', 'pending'], type: 'builtin' }
    ]

    beforeAll(() => {
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

      selectProduct(wrapper, selectedProduct)
      expect(isButtonDisabled(wrapper)).toBe(true)

      selectApplicationPlan(wrapper, appPlans[0])
      expect(isButtonDisabled(wrapper)).toBe(true)

      act(() => wrapper.find('UserDefinedField').at(0).props().onChange('My Name'))
      wrapper.update()
      expect(isButtonDisabled(wrapper)).toBe(true)

      act(() => wrapper.find('UserDefinedField').at(1).props().onChange('Active'))
      wrapper.update()
      expect(isButtonDisabled(wrapper)).toBe(false)
    })
  })
})

describe('when in Audience context', () => {
  const props = {
    ...defaultProps,
    mostRecentlyCreatedBuyers: buyers,
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
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectBuyer(wrapper, buyer)
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectProduct(wrapper, products[0])
    expect(isButtonDisabled(wrapper)).toBe(true)

    selectApplicationPlan(wrapper, appPlans[0])
    expect(isButtonDisabled(wrapper)).toBe(false)
  })

  describe('when service plans are allowed', () => {
    beforeAll(() => {
      props.servicePlansAllowed = true
    })

    describe('when the selected buyer is subscribed to the selected product', () => {
      const servicePlan = { id: 0, name: 'Service Plan' }
      const selectedProduct = { ...products[0], servicePlans: [servicePlan] }
      const { id, name } = selectedProduct
      const selectedBuyer = { ...buyer, contractedProducts: [{ id: Number(id), name: name, withPlan: servicePlan }] }

      beforeAll(() => {
        props.mostRecentlyCreatedBuyers = [selectedBuyer]
        props.mostRecentlyUpdatedProducts = [selectedProduct]
      })

      it('should have a service plan selected', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, selectedBuyer)
        selectProduct(wrapper, selectedProduct)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toEqual(servicePlan)
        expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
      })

      it('should not be able to change the service plan', () => {
        const wrapper = mountWrapper(props)

        selectBuyer(wrapper, selectedBuyer)
        selectProduct(wrapper, selectedProduct)

        expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
      })
    })

    describe('when the selected buyer is not subscribed to the selected product', () => {
      const selectedBuyer = { ...buyer, contractedProducts: [] }

      beforeAll(() => {
        props.mostRecentlyCreatedBuyers = [selectedBuyer]
      })

      describe('when it has no service plans', () => {
        const selectedProduct = { ...products[0], servicePlans: [] }

        beforeAll(() => {
          props.mostRecentlyUpdatedProducts = [selectedProduct]
        })

        it('should not be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(true)
        })

        it('should not have a service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBeNull()
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(false)
        })

        it('should hint the user to create a service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('ServicePlanSelect .hint')).toMatchSnapshot()
        })
      })

      describe('when it has service plans and one is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (default)' }
        ]
        const defaultServicePlan = servicePlans[1]
        const selectedProduct = { ...products[0], servicePlans, defaultServicePlan }

        beforeAll(() => {
          props.mostRecentlyUpdatedProducts = [selectedProduct]
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(defaultServicePlan)
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)

          selectServicePlan(wrapper, servicePlans[0])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).not.toBe(defaultServicePlan)
        })

        it('should have the default service plan selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[1])
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })
      })

      describe('when the selected product has service plans but none is default', () => {
        const servicePlans = [
          { id: 0, name: 'First Plan (not default)' },
          { id: 1, name: 'Second Plan (not default)' }
        ]
        const selectedProduct = { ...products[0], servicePlans, defaultServicePlan: undefined }

        beforeAll(() => {
          props.mostRecentlyUpdatedProducts = [selectedProduct]
        })

        it('should be able to change the service plan', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[0])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').props().isDisabled).toBe(false)

          selectServicePlan(wrapper, servicePlans[1])
          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[1])
        })

        it('should have the first service plan, not the default one, selected', () => {
          const wrapper = mountWrapper(props)

          selectBuyer(wrapper, selectedBuyer)
          selectProduct(wrapper, selectedProduct)

          expect(wrapper.find('Select[name="cinstance[service_plan_id]"]').prop('item')).toBe(servicePlans[0])
          expect(wrapper.find('input[type="hidden"][name="cinstance[service_plan_id]"]').exists()).toBe(true)
        })
      })
    })
  })
})
