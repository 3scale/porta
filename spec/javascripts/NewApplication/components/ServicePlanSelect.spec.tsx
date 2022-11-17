import { mount } from 'enzyme'

import { ServicePlanSelect } from 'NewApplication/components/ServicePlanSelect'

import type { Props } from 'NewApplication/components/ServicePlanSelect'
import type { ReactWrapper } from 'enzyme'

const defaultProps = {
  servicePlan: null,
  servicePlans: null,
  onSelect: jest.fn(),
  isPlanContracted: false,
  isDisabled: undefined,
  serviceSubscriptionsPath: '/foo',
  createServicePlanPath: '/bar'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ServicePlanSelect {...{ ...defaultProps, ...props }} />)

const isDisabled = (wrapper: ReactWrapper<unknown>, isDisabled = true): boolean => {
  return wrapper.exists('.pf-c-select .pf-m-disabled') === isDisabled
    && wrapper.find('input.pf-c-select__toggle-typeahead').props().disabled === isDisabled
    && wrapper.find('button.pf-c-select__toggle-button').props().disabled === isDisabled
}

it('should be disabled', () => {
  const wrapper = mountWrapper({ isDisabled: true })
  expect(isDisabled(wrapper)).toEqual(true)
})

describe('when plan is contracted', () => {
  const props = { ...defaultProps, isPlanContracted: true }

  it('should show a hint and be disabled', () => {
    const wrapper = mountWrapper(props)
    expect(isDisabled(wrapper)).toEqual(true)
    expect(wrapper.exists('.hint')).toEqual(true)
    expect(wrapper.find('.hint').find('a').prop('href')).toEqual(props.serviceSubscriptionsPath)
  })
})

describe('when plan is not contracted', () => {
  describe('and there are some plans', () => {
    const props = { ...defaultProps, isPlanContracted: false, servicePlans: [{ id: 0, name: 'service plan' }] }

    it('should show a hint', () => {
      const wrapper = mountWrapper(props)
      expect(isDisabled(wrapper, false)).toEqual(true)
      expect(wrapper.exists('.hint')).toEqual(true)
      expect(wrapper.find('.hint').exists('a')).toEqual(false)
    })
  })

  describe('and there are no plans', () => {
    const props = { ...defaultProps, isPlanContracted: false, servicePlans: [] }

    it('should show a hint and a link to create a new plan', () => {
      const wrapper = mountWrapper(props)
      expect(isDisabled(wrapper, false)).toEqual(true)
      expect(wrapper.exists('.hint')).toEqual(true)
      expect(wrapper.find('.hint').find('a').prop('href')).toEqual(props.createServicePlanPath)
    })
  })

  describe('and plans is null', () => {
    const props = { ...defaultProps, isPlanContracted: false, servicePlans: null }

    it('should show a hint and a link to create a new plan', () => {
      const wrapper = mountWrapper(props)
      expect(isDisabled(wrapper, false)).toEqual(true)
      expect(wrapper.exists('.hint')).toEqual(true)
      expect(wrapper.find('.hint').exists('a')).toEqual(false)
    })
  })
})
