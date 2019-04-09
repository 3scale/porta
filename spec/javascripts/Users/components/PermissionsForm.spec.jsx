import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { PermissionsForm } from 'Users/components/PermissionsForm'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (testProps) {
  const defaultProps = { features: [], services: [] }
  const props = { ...defaultProps, ...testProps }

  wrapper = mount(<PermissionsForm { ...props } />)
}

let wrapper

beforeEach(() => {
  getWrapper()
})

afterEach(() => {
  wrapper.unmount()
})

it('should render itself', () => {
  expect(wrapper.find(PermissionsForm).exists()).toBe(true)
})

it('should have a legend with a the name of the form', () => {
  const legend = wrapper.find('legend').findWhere(n => n.text() === 'Administrative')
  expect(legend.exists()).toBe(true)
})

it('should do nothing if selecting the same role twice', () => {
  expect(wrapper.find('input#user_role_admin').props().checked).toBe(true)
  expect(wrapper.find('input#user_role_member').props().checked).toBe(false)

  wrapper.find('input#user_role_admin').simulate('change')

  expect(wrapper.find('input#user_role_admin').props().checked).toBe(true)
  expect(wrapper.find('input#user_role_member').props().checked).toBe(false)
})

it('should be able to change the role', () => {
  expect(wrapper.find('input#user_role_admin').prop('checked')).toBe(true)
  expect(wrapper.find('input#user_role_member').prop('checked')).toBe(false)

  wrapper.find('input#user_role_member').simulate('change')

  expect(wrapper.find('input#user_role_admin').prop('checked')).toBe(false)
  expect(wrapper.find('input#user_role_member').prop('checked')).toBe(true)
})

describe('when role is "admin"', () => {
  beforeEach(() => {
    wrapper.find('input#user_role_admin').simulate('change')
    wrapper.update()
  })

  it('should render nothing more', () => {
    expect(wrapper.find('RoleRadioGroup').exists()).toBe(true)
    expect(wrapper.find('#user_member_permissions_input').exists()).toBe(false)
  })
})

describe('when role is "member"', () => {
  const findFeatures = () => wrapper.find('input[type="checkbox"][name="user[member_permission_ids][]"]')
  const FEATURES = ['portal', 'finance', 'settings', 'policy_registry']
  const FEATURES_FOR_SERVICES = ['partners', 'monitoring', 'plans']
  const allFeatures = [ ...FEATURES, ...FEATURES_FOR_SERVICES ]

  beforeEach(() => {
    getWrapper({
      initialState: { role: 'member' },
      features: allFeatures
    })
  })

  it('should render the given features', () => {
    getWrapper({
      initialState: { role: 'member' },
      features: ['portal', 'finance', 'settings']
    })

    // $FlowFixMe: waiting for https://github.com/facebook/flow/pull/7298 to be merged
    expect(wrapper.containsAllMatchingElements([
      <input id={'user_member_permission_ids_portal'} />,
      <input id={'user_member_permission_ids_finance'} />,
      <input id={'user_member_permission_ids_settings'} />
    ])).toBe(true)

    // $FlowFixMe: waiting for https://github.com/facebook/flow/pull/7298 to be merged
    expect(wrapper.containsAllMatchingElements([
      <input id={'user_member_permission_ids_partners'} />,
      <input id={'user_member_permission_ids_monitoring'} />,
      <input id={'user_member_permission_ids_plans'} />
    ])).toBe(false)

    getWrapper({
      initialState: { role: 'member' },
      features: ['partners', 'monitoring', 'plans']
    })

    // $FlowFixMe: waiting for https://github.com/facebook/flow/pull/7298 to be merged
    expect(wrapper.containsAllMatchingElements([
      <input id={'user_member_permission_ids_partners'} />,
      <input id={'user_member_permission_ids_monitoring'} />,
      <input id={'user_member_permission_ids_plans'} />
    ])).toBe(true)

    // $FlowFixMe: waiting for https://github.com/facebook/flow/pull/7298 to be merged
    expect(wrapper.containsAllMatchingElements([
      <input id={'user_member_permission_ids_portal'} />,
      <input id={'user_member_permission_ids_finance'} />,
      <input id={'user_member_permission_ids_settings'} />
    ])).toBe(false)
  })

  it('should have no checked features by default', () => {
    expect(findFeatures()).toHaveLength(allFeatures.length)
    expect(findFeatures().some({ checked: true })).toBe(false)
  })

  it('should be able to select features', () => {
    expect(findFeatures().every({ checked: false })).toBe(true)

    findFeatures().at(0).simulate('change')
    expect(findFeatures().at(0).prop('checked')).toBe(true)

    findFeatures().at(0).simulate('change')
    expect(findFeatures().find({ checked: true })).toHaveLength(0)

    findFeatures().at(1).simulate('change')
    expect(findFeatures().find({ checked: true })).toHaveLength(1)
    findFeatures().at(2).simulate('change')
    expect(findFeatures().find({ checked: true })).toHaveLength(2)
  })

  it('should render a "services" checkbox if any feature granting service access is checked', () => {
    // Features granting services access
    FEATURES_FOR_SERVICES.forEach(feature => {
      expect(findFeatures().some({ checked: true })).toBe(false)
      expect(wrapper.find('user_member_permission_ids_services').exists()).toBe(false)

      findFeatures().find(`#user_member_permission_ids_${feature}`).simulate('change')
      expect(wrapper.find('#user_member_permission_ids_services').exists()).toBe(true)

      findFeatures().find(`#user_member_permission_ids_${feature}`).simulate('change')
    })

    // Features NOT granting services access
    FEATURES.forEach(feature => {
      expect(findFeatures().some({ checked: true })).toBe(false)
      expect(wrapper.find('user_member_permission_ids_services').exists()).toBe(false)

      findFeatures().find(`#user_member_permission_ids_${feature}`).simulate('change')
      expect(wrapper.find('#user_member_permission_ids_services').exists()).toBe(false)

      findFeatures().find(`#user_member_permission_ids_${feature}`).simulate('change')
    })
  })

  const SERVICES = [{ id: 0, name: 'The Super API', link: '' }, { id: 1, name: 'Cool Villains', link: '' }]

  describe('when "services" checkbox is visible and included in admin_sections', () => {
    beforeEach(() => {
      getWrapper({
        initialState: { role: 'member', admin_sections: ['partners', 'services'] },
        services: SERVICES
      })
    })

    it('should render all services enabled', () => {
      expect(wrapper.find('ServiceCheckbox')).toHaveLength(SERVICES.length)
      expect(wrapper.find('ServiceCheckbox').everyWhere(n => !n.prop('disabled'))).toBe(true)
    })

    it('should render "services" checkbox unchecked', () => {
      expect(wrapper.find('AllServicesCheckbox').prop('checked')).toBe(false)
    })

    it('should render all services included in "selectedServicesIds" checked', () => {
      getWrapper({
        initialState: { role: 'member', admin_sections: ['partners', 'services'], member_permission_service_ids: [SERVICES[0].id] },
        services: SERVICES
      })

      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toBe(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toBe(false)
    })

    it('should check and uncheck services when clicked', () => {
      expect(wrapper.find('ServiceCheckbox').find('input[type="checkbox"]').every({ checked: false })).toBe(true)

      wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).simulate('change')
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toBe(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toBe(false)

      wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).simulate('change')
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toBe(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toBe(true)

      wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).simulate('change')
      expect(wrapper.find(`input#user_member_permission_service_ids_${0}`).prop('checked')).toBe(false)
      expect(wrapper.find(`input#user_member_permission_service_ids_${1}`).prop('checked')).toBe(true)
    })
  })

  describe('when "services" checkbox is visible and NOT selected', () => {
    beforeEach(() => {
      getWrapper({
        initialState: { role: 'member', admin_sections: ['partners'] },
        services: SERVICES
      })
    })

    it('should render AllServicesCheckbox checked', () => {
      expect(wrapper.find('input[name="user[member_permission_service_ids]"]').prop('checked')).toBe(true)
    })

    it('should render all services checked and disabled', () => {
      expect(wrapper.find('input[name="user[member_permission_service_ids][]"]')).toHaveLength(SERVICES.length)
      expect(wrapper.find('input[name="user[member_permission_service_ids][]"]').every({ checked: true, disabled: true })).toBe(true)
    })
  })
})
