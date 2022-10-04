import { mount } from 'enzyme'
import { FeaturesFieldset } from 'Users/components/FeaturesFieldset'

import type { ReactWrapper } from 'enzyme'
import type { Props } from 'Users/components/FeaturesFieldset'
import type { AdminSection, Feature } from 'Users/types'

let wrapper: ReactWrapper

const FEATURES = ['plans', 'monitoring', 'settings']

function getWrapper (testProps?: Partial<Props>) {
  const defaultProps: Props = {
    features: FEATURES as Feature[],
    onAdminSectionSelected: jest.fn()
  }
  const props: Props = { ...defaultProps, ...testProps }

  wrapper = mount(<FeaturesFieldset {...props} />)
}

beforeEach(() => {
  getWrapper()
})

afterEach(() => {
  wrapper.unmount()
})

it('should render itself', () => {
  expect(wrapper.find(FeaturesFieldset).exists()).toBe(true)
})

it('should render a hidden input', () => {
  expect(wrapper.containsMatchingElement(
    <input name="user[member_permission_ids][]" type="hidden" />
  )).toBe(true)
})

it('should have each input the correct id', () => {
  FEATURES.forEach(feature => {
    expect(wrapper.find(`input#user_member_permission_ids_${feature}`).exists()).toBe(true)
  })
})

it('should render inputs checked if included in "selectedSections"', () => {
  getWrapper({ selectedSections: ['plans'] as AdminSection[] })
  expect(wrapper.find('input[type="checkbox"]').find({ checked: true }).prop('value')).toEqual('plans')

  getWrapper({ selectedSections: FEATURES as AdminSection[] })
  expect(wrapper.find('input[type="checkbox"]').find({ checked: true })).toHaveLength(FEATURES.length)
})

it('should call onAdminSectionSelected when a selecting a checkbox', () => {
  const onAdminSectionSelected = jest.fn()
  getWrapper({ onAdminSectionSelected })

  wrapper.find('input#user_member_permission_ids_plans').simulate('change')
  expect(onAdminSectionSelected).toHaveBeenCalledWith('plans')
})

it('should render label description items', () => {
  getWrapper()
  expect(wrapper.find('.FeatureAccessList-item--labelDescription').exists()).toBe(true)
})

describe('when services are hidden', () => {
  beforeEach(() => {
    getWrapper({ areServicesVisible: false })
  })

  it('should have "noServicePermissionsGranted" class', () => {
    expect(wrapper.find('.FeatureAccessList--noServicePermissionsGranted').exists()).toBe(true)
  })

  it('should render a checkbox input per feature', () => {
    expect(wrapper.find('input[type="checkbox"]')).toHaveLength(FEATURES.length)
  })
})

describe('when services are visible', () => {
  beforeEach(() => {
    getWrapper({ areServicesVisible: true })
  })

  it('should not have "noServicePermissionsGranted" class', () => {
    expect(wrapper.find('.FeatureAccessList--noServicePermissionsGranted').exists()).toBe(false)
  })

  it('should render an additional checkbox input if services are visible', () => {
    expect(wrapper.find('input[type="checkbox"]')).toHaveLength(FEATURES.length + 1)
    expect(wrapper.find('input#user_member_permission_ids_services').exists()).toBe(true)
  })

  it('should render "services" checked if not included in selectedSections', () => {
    getWrapper({ areServicesVisible: true, selectedSections: [] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(true)

    getWrapper({ areServicesVisible: true, selectedSections: ['services'] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(false)
  })

  it('should render a hidden input when "services" is not selected', () => {
    getWrapper({ areServicesVisible: true, selectedSections: [] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(true)
    expect(wrapper.find('input').find({ name: 'user[member_permission_service_ids][]' }).exists()).toBe(false)

    getWrapper({ areServicesVisible: true, selectedSections: ['services'] as AdminSection[] })
    expect(wrapper.find('input#user_member_permission_ids_services').prop('checked')).toBe(false)
    expect(wrapper.find('input').find({ name: 'user[member_permission_service_ids][]' }).exists()).toBe(true)
  })

  it('should call onAdminSectionSelected when a selecting "services"', () => {
    const onAdminSectionSelected = jest.fn()
    getWrapper({ areServicesVisible: true, onAdminSectionSelected })

    wrapper.find('input#user_member_permission_ids_services').simulate('change')
    expect(onAdminSectionSelected).toHaveBeenCalledWith('services')
  })
})
