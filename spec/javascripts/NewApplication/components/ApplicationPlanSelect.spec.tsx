import { mount } from 'enzyme'

import { ApplicationPlanSelect } from 'NewApplication/components/ApplicationPlanSelect'

import type { Props } from 'NewApplication/components/ApplicationPlanSelect'
import type { ReactWrapper } from 'enzyme'
import type { Plan, Product } from 'NewApplication/types'

const appPlan: Plan = { id: 0, name: 'The Plan' }
const createApplicationPlanPath = '/plans'
const defaultProps = {
  product: null,
  appPlan: null,
  createApplicationPlanPath,
  onSelect: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ApplicationPlanSelect {...{ ...defaultProps, ...props }} />)

const isDisabled = (wrapper: ReactWrapper<unknown>, isDisabled = true): boolean => {
  return wrapper.find('.pf-c-select .pf-m-disabled').exists() === isDisabled
    && wrapper.find('input.pf-c-select__toggle-typeahead').props().disabled === isDisabled
    && wrapper.find('button.pf-c-select__toggle-button').props().disabled === isDisabled
}

describe('when no product selected', () => {
  const props = { product: null }

  it('should be disabled when no product is selected', () => {
    const wrapper = mountWrapper(props)
    expect(isDisabled(wrapper)).toEqual(true)
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
    defaultServicePlan: null,
    defaultAppPlan: null
  }
  const props = { product }

  it('should not be disabled', () => {
    const wrapper = mountWrapper(props)
    expect(isDisabled(wrapper, false)).toEqual(true)
  })

  describe('and the product has some application plans', () => {
    const props = { product: { ...product, appPlans: [appPlan] } }

    it('should not be disabled', () => {
      const wrapper = mountWrapper(props)
      expect(isDisabled(wrapper, false)).toEqual(true)
    })
  })

  describe('but the product has no application plans', () => {
    const props = { product: { ...product, appPlans: [] } }

    it('should show a hint with a link to create a plan', () => {
      const wrapper = mountWrapper(props)
      const hint = wrapper.find('.hint')
      expect(hint.exists()).toBe(true)
      expect(hint.find('a').props().href).toEqual(createApplicationPlanPath)
    })

    it('should be disabled', () => {
      const wrapper = mountWrapper(props)
      expect(isDisabled(wrapper)).toEqual(true)
    })
  })
})
