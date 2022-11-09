import { mount } from 'enzyme'

import { FeaturesFieldset } from 'Users/components/FeaturesFieldset'

import type { Props } from 'Users/components/FeaturesFieldset'
import type { Feature } from 'Users/types'

const FEATURES = ['plans', 'monitoring', 'settings'] as Feature[]

const defaultProps: Props = {
  features: FEATURES,
  onAdminSectionSelected: jest.fn()
}
const mountWrapper = (props: Partial<Props> = {}) => mount(<FeaturesFieldset {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(FeaturesFieldset)).toEqual(true)
})

it('should render a hidden input', () => {
  const wrapper = mountWrapper()
  expect(wrapper.containsMatchingElement(
    <input name="user[member_permission_ids][]" type="hidden" />
  )).toEqual(true)
})

it('should have each input the correct id', () => {
  const wrapper = mountWrapper()
  FEATURES.forEach(feature => {
    expect(wrapper.exists(`input#user_member_permission_ids_${feature}`)).toEqual(true)
  })
})

it('should render inputs checked if included in "selectedSections"', () => {
  const wrapper = mountWrapper({ selectedSections: ['plans'] })
  expect(wrapper.find('input[type="checkbox"]').find({ checked: true }).prop('value')).toEqual('plans')

  wrapper.setProps({ selectedSections: FEATURES })
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
  expect(wrapper.exists('.FeatureAccessList-item--labelDescription')).toEqual(true)
})

describe('when services are hidden', () => {
  const props = { areServicesVisible: false }

  it('should have "noServicePermissionsGranted" class', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists('.FeatureAccessList--noServicePermissionsGranted')).toEqual(true)
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
    expect(wrapper.exists('.FeatureAccessList--noServicePermissionsGranted')).toEqual(false)
  })

  it('should render an additional checkbox input if services are visible', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[type="checkbox"]')).toHaveLength(FEATURES.length + 1)
    expect(wrapper.exists('input#user_member_permission_ids_services')).toEqual(true)
  })

  it('should render "services" checked if not included in selectedSections', () => {
    const wrapper = mountWrapper({ areServicesVisible: true, selectedSections: [] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toEqual(true)

    wrapper.setProps({ areServicesVisible: true, selectedSections: ['services'] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toEqual(false)
  })

  it('should render a hidden input when "services" is not selected', () => {
    const wrapper = mountWrapper({ areServicesVisible: true, selectedSections: [] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toEqual(true)
    expect(wrapper.find('input').exists({ name: 'user[member_permission_service_ids][]' })).toEqual(false)

    wrapper.setProps({ areServicesVisible: true, selectedSections: ['services'] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toEqual(false)
    expect(wrapper.find('input').exists({ name: 'user[member_permission_service_ids][]' })).toEqual(true)
  })

  it('should call onAdminSectionSelected when a selecting "services"', () => {
    const onAdminSectionSelected = jest.fn()
    const wrapper = mountWrapper({ areServicesVisible: true, onAdminSectionSelected })

    wrapper.find('input#user_member_permission_ids_services').simulate('change')
    expect(onAdminSectionSelected).toHaveBeenCalledWith('services')
  })
})

it('should throw an error if feature is wrong', () => {
  // @ts-expect-error We need to pass a wrong feature value
  expect(() => mountWrapper({ features: ['foo'] })).toThrowError('foo is not a known feature')
})
