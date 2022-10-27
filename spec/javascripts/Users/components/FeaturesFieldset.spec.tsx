import { mount } from 'enzyme'
import { FeaturesFieldset } from 'Users/components/FeaturesFieldset'

import type { Props } from 'Users/components/FeaturesFieldset'
import type { AdminSection, Feature } from 'Users/types'

const FEATURES = ['plans', 'monitoring', 'settings']

const defaultProps: Props = {
  features: FEATURES as Feature[],
  onAdminSectionSelected: jest.fn()
}
const mountWrapper = (props: Partial<Props> = {}) => mount(<FeaturesFieldset {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(FeaturesFieldset).exists()).toBe(true)
})

it('should render a hidden input', () => {
  const wrapper = mountWrapper()
  expect(wrapper.containsMatchingElement(
    <input name="user[member_permission_ids][]" type="hidden" />
  )).toBe(true)
})

it('should have each input the correct id', () => {
  const wrapper = mountWrapper()
  FEATURES.forEach(feature => {
    expect(wrapper.find(`input#user_member_permission_ids_${feature}`).exists()).toBe(true)
  })
})

it('should render inputs checked if included in "selectedSections"', () => {
  const wrapper = mountWrapper({ selectedSections: ['plans'] as AdminSection[] })
  expect(wrapper.find('input[type="checkbox"]').find({ checked: true }).prop('value')).toEqual('plans')

  wrapper.setProps({ selectedSections: FEATURES as AdminSection[] })
  expect(wrapper.find('input[type="checkbox"]').find({ checked: true })).toHaveLength(FEATURES.length)
})

it('should call onAdminSectionSelected when a selecting a checkbox', () => {
  const onAdminSectionSelected = jest.fn()
  const wrapper = mountWrapper({ onAdminSectionSelected })

  wrapper.find('input#user_member_permission_ids_plans').simulate('change')
  expect(onAdminSectionSelected).toHaveBeenCalledWith('plans')
})

it('should render label description items', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.FeatureAccessList-item--labelDescription').exists()).toBe(true)
})

describe('when services are hidden', () => {
  const props = { areServicesVisible: false }

  it('should have "noServicePermissionsGranted" class', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('.FeatureAccessList--noServicePermissionsGranted').exists()).toBe(true)
  })

  it('should render a checkbox input per feature', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[type="checkbox"]')).toHaveLength(FEATURES.length)
  })
})

describe('when services are visible', () => {
  const props = { areServicesVisible: true }

  it('should not have "noServicePermissionsGranted" class', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('.FeatureAccessList--noServicePermissionsGranted').exists()).toBe(false)
  })

  it('should render an additional checkbox input if services are visible', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[type="checkbox"]')).toHaveLength(FEATURES.length + 1)
    expect(wrapper.find('input#user_member_permission_ids_services').exists()).toBe(true)
  })

  it('should render "services" checked if not included in selectedSections', () => {
    const wrapper = mountWrapper({ areServicesVisible: true, selectedSections: [] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(true)

    wrapper.setProps({ areServicesVisible: true, selectedSections: ['services'] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(false)
  })

  it('should render a hidden input when "services" is not selected', () => {
    const wrapper = mountWrapper({ areServicesVisible: true, selectedSections: [] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(true)
    expect(wrapper.find('input').find({ name: 'user[member_permission_service_ids][]' }).exists()).toBe(false)

    wrapper.setProps({ areServicesVisible: true, selectedSections: ['services'] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(false)
    expect(wrapper.find('input').find({ name: 'user[member_permission_service_ids][]' }).exists()).toBe(true)
  })

  it('should call onAdminSectionSelected when a selecting "services"', () => {
    const onAdminSectionSelected = jest.fn()
    const wrapper = mountWrapper({ areServicesVisible: true, onAdminSectionSelected })

    wrapper.find('input#user_member_permission_ids_services').simulate('change')
    expect(onAdminSectionSelected).toHaveBeenCalledWith('services')
  })
})
