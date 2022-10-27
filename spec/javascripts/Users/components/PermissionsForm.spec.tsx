import { mount } from 'enzyme'
import { PermissionsForm } from 'Users/components/PermissionsForm'

import type { ReactWrapper } from 'enzyme'
import type { Props } from 'Users/components/PermissionsForm'
import type { AdminSection, Feature, Role } from 'Users/types'
import type { Api } from 'Types'

const defaultProps: Props = { features: [], services: [] }
const mountWrapper = (props: Partial<Props> = {}) => mount(<PermissionsForm {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  expect(mountWrapper().find(PermissionsForm).exists()).toBe(true)
})

it('should have a legend with a the name of the form', () => {
  const legend = mountWrapper().find('legend').findWhere(n => n.text() === 'Administrative')
  expect(legend.exists()).toBe(true)
})

it('should do nothing if selecting the same role twice', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('input#user_role_admin').props().checked).toBe(true)
  expect(wrapper.find('input#user_role_member').props().checked).toBe(false)

  wrapper.find('input#user_role_admin').simulate('change')

  expect(wrapper.find('input#user_role_admin').props().checked).toBe(true)
  expect(wrapper.find('input#user_role_member').props().checked).toBe(false)
})

it('should be able to change the role', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('input#user_role_admin').prop('checked')).toBe(true)
  expect(wrapper.find('input#user_role_member').prop('checked')).toBe(false)

  wrapper.find('input#user_role_member').simulate('change')

  expect(wrapper.find('input#user_role_admin').prop('checked')).toBe(false)
  expect(wrapper.find('input#user_role_member').prop('checked')).toBe(true)
})

describe('when role is "admin"', () => {
  const wrapper = mountWrapper()
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
  const FEATURES: Feature[] = ['portal', 'finance', 'settings', 'policy_registry']
  const FEATURES_FOR_SERVICES: Feature[] = ['partners', 'monitoring', 'plans']
  const allFeatures: Feature[] = [...FEATURES, ...FEATURES_FOR_SERVICES]

  const props = {
    initialState: { role: 'member' as Role },
    features: allFeatures
  }

  const findFeatures = (wrapper: ReactWrapper<unknown>) => wrapper.find('input[type="checkbox"][name="user[member_permission_ids][]"]') as ReactWrapper

  it('should render the given features', () => {
    const wrapper = mountWrapper({
      initialState: { role: 'member' as Role },
      features: ['portal', 'finance', 'settings'] as Feature[]
    })

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_portal" />,
      <input id="user_member_permission_ids_finance" />,
      <input id="user_member_permission_ids_settings" />
    ])).toBe(true)

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_partners" />,
      <input id="user_member_permission_ids_monitoring" />,
      <input id="user_member_permission_ids_plans" />
    ])).toBe(false)

    wrapper.setProps({
      initialState: { role: 'member' as Role },
      features: ['partners', 'monitoring', 'plans'] as Feature[]
    })

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_partners" />,
      <input id="user_member_permission_ids_monitoring" />,
      <input id="user_member_permission_ids_plans" />
    ])).toBe(true)

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_portal" />,
      <input id="user_member_permission_ids_finance" />,
      <input id="user_member_permission_ids_settings" />
    ])).toBe(false)
  })

  it('should have no checked features by default', () => {
    const wrapper = mountWrapper(props)
    expect(findFeatures(wrapper)).toHaveLength(allFeatures.length)
    expect(findFeatures(wrapper).some({ checked: true })).toBe(false)
  })

  it('should be able to select features', () => {
    const wrapper = mountWrapper(props)
    expect(findFeatures(wrapper).every({ checked: false })).toBe(true)

    findFeatures(wrapper).at(0).simulate('change')
    expect(findFeatures(wrapper).at(0).prop('checked')).toBe(true)

    findFeatures(wrapper).at(0).simulate('change')
    expect(findFeatures(wrapper).find({ checked: true })).toHaveLength(0)

    findFeatures(wrapper).at(1).simulate('change')
    expect(findFeatures(wrapper).find({ checked: true })).toHaveLength(1)
    findFeatures(wrapper).at(2).simulate('change')
    expect(findFeatures(wrapper).find({ checked: true })).toHaveLength(2)
  })

  it('should render a "services" checkbox if any feature granting service access is checked', () => {
    const wrapper = mountWrapper(props)

    // Features granting services access
    FEATURES_FOR_SERVICES.forEach(feature => {
      expect(findFeatures(wrapper).some({ checked: true })).toBe(false)
      expect(wrapper.find('user_member_permission_ids_services').exists()).toBe(false)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
      expect(wrapper.find('#user_member_permission_ids_services').exists()).toBe(true)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
    })

    // Features NOT granting services access
    FEATURES.forEach(feature => {
      expect(findFeatures(wrapper).some({ checked: true })).toBe(false)
      expect(wrapper.find('user_member_permission_ids_services').exists()).toBe(false)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
      expect(wrapper.find('#user_member_permission_ids_services').exists()).toBe(false)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
    })
  })

  const SERVICES = [{ id: 0, name: 'The Super API', link: '' }, { id: 1, name: 'Cool Villains', link: '' }]

  describe('when "services" checkbox is visible and included in admin_sections', () => {
    const props = {
      initialState: { role: 'member' as Role, admin_sections: ['partners', 'services'] as AdminSection[] },
      services: SERVICES as Api[]
    }

    it('should render all services enabled', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('ServiceCheckbox')).toHaveLength(SERVICES.length)
      expect(wrapper.find('ServiceCheckbox').everyWhere(n => !n.prop('disabled'))).toBe(true)
    })

    it('should render "services" checkbox unchecked', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('AllServicesCheckbox').prop('checked')).toBe(false)
    })

    it('should render all services included in "selectedServicesIds" checked', () => {
      const wrapper = mountWrapper({
        initialState: { role: 'member' as Role, admin_sections: ['partners', 'services'] as AdminSection[], member_permission_service_ids: [SERVICES[0].id] },
        services: SERVICES as Api[]
      })

      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toBe(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toBe(false)
    })

    it('should check and uncheck services when clicked', () => {
      const wrapper = mountWrapper(props)
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
    const props = {
      initialState: { role: 'member' as Role, admin_sections: ['partners'] as AdminSection[] },
      services: SERVICES as Api[]
    }

    it('should render AllServicesCheckbox checked', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('input[name="user[member_permission_service_ids]"]').prop('checked')).toBe(true)
    })

    it('should render all services checked and disabled', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('input[name="user[member_permission_service_ids][]"]')).toHaveLength(SERVICES.length)
      expect(wrapper.find('input[name="user[member_permission_service_ids][]"]').every({ checked: true, disabled: true })).toBe(true)
    })
  })
})
