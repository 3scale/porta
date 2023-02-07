import { mount } from 'enzyme'

import { PermissionsForm } from 'Users/components/PermissionsForm'

import type { ReactWrapper } from 'enzyme'
import type { Props } from 'Users/components/PermissionsForm'
import type { AdminSection, Feature, Role } from 'Users/types'
import type { Api } from 'Types'

const defaultProps: Props = { features: [], services: [] }
const mountWrapper = (props: Partial<Props> = {}) => mount(<PermissionsForm {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  expect(mountWrapper().exists(PermissionsForm)).toEqual(true)
})

it('should have a legend with a the name of the form', () => {
  const legend = mountWrapper().find('legend').findWhere(n => n.text() === 'Administrative')
  expect(legend.exists()).toEqual(true)
})

it('should do nothing if selecting the same role twice', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('input#user_role_admin').props().checked).toEqual(true)
  expect(wrapper.find('input#user_role_member').props().checked).toEqual(false)

  wrapper.find('input#user_role_admin').simulate('change')

  expect(wrapper.find('input#user_role_admin').props().checked).toEqual(true)
  expect(wrapper.find('input#user_role_member').props().checked).toEqual(false)
})

it('should be able to change the role', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('input#user_role_admin').prop('checked')).toEqual(true)
  expect(wrapper.find('input#user_role_member').prop('checked')).toEqual(false)

  wrapper.find('input#user_role_member').simulate('change')

  expect(wrapper.find('input#user_role_admin').prop('checked')).toEqual(false)
  expect(wrapper.find('input#user_role_member').prop('checked')).toEqual(true)
})

describe('when role is "admin"', () => {
  const wrapper = mountWrapper()
  beforeEach(() => {
    wrapper.find('input#user_role_admin').simulate('change')
    wrapper.update()
  })

  it('should render nothing more', () => {
    expect(wrapper.exists('RoleRadioGroup')).toEqual(true)
    expect(wrapper.exists('#user_member_permissions_input')).toEqual(false)
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
    ])).toEqual(true)

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_partners" />,
      <input id="user_member_permission_ids_monitoring" />,
      <input id="user_member_permission_ids_plans" />
    ])).toEqual(false)

    wrapper.setProps({
      initialState: { role: 'member' as Role },
      features: ['partners', 'monitoring', 'plans'] as Feature[]
    })

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_partners" />,
      <input id="user_member_permission_ids_monitoring" />,
      <input id="user_member_permission_ids_plans" />
    ])).toEqual(true)

    expect(wrapper.containsAllMatchingElements([
      <input id="user_member_permission_ids_portal" />,
      <input id="user_member_permission_ids_finance" />,
      <input id="user_member_permission_ids_settings" />
    ])).toEqual(false)
  })

  it('should have no checked features by default', () => {
    const wrapper = mountWrapper(props)
    expect(findFeatures(wrapper)).toHaveLength(allFeatures.length)
    expect(findFeatures(wrapper).some({ checked: true })).toEqual(false)
  })

  it('should be able to select features', () => {
    const wrapper = mountWrapper(props)
    expect(findFeatures(wrapper).every({ checked: false })).toEqual(true)

    findFeatures(wrapper).at(0).simulate('change')
    expect(findFeatures(wrapper).at(0).prop('checked')).toEqual(true)

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
      expect(findFeatures(wrapper).some({ checked: true })).toEqual(false)
      expect(wrapper.exists('user_member_permission_ids_services')).toEqual(false)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
      expect(wrapper.exists('#user_member_permission_ids_services')).toEqual(true)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
    })

    // Features NOT granting services access
    FEATURES.forEach(feature => {
      expect(findFeatures(wrapper).some({ checked: true })).toEqual(false)
      expect(wrapper.exists('user_member_permission_ids_services')).toEqual(false)

      findFeatures(wrapper).find(`#user_member_permission_ids_${feature}`).simulate('change')
      expect(wrapper.exists('#user_member_permission_ids_services')).toEqual(false)

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
      expect(wrapper.find('ServiceCheckbox').everyWhere(n => !n.prop('disabled'))).toEqual(true)
    })

    it('should render "services" checkbox unchecked', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('AllServicesCheckbox').prop('checked')).toEqual(false)
    })

    it('should render all services included in "selectedServicesIds" checked', () => {
      const wrapper = mountWrapper({
        initialState: { role: 'member' as Role, admin_sections: ['partners', 'services'] as AdminSection[], member_permission_service_ids: [SERVICES[0].id] },
        services: SERVICES as Api[]
      })

      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toEqual(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toEqual(false)
    })

    it('should check and uncheck services when clicked', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('ServiceCheckbox').find('input[type="checkbox"]').every({ checked: false })).toEqual(true)

      wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).simulate('change')
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toEqual(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toEqual(false)

      wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).simulate('change')
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).prop('checked')).toEqual(true)
      expect(wrapper.find(`input#user_member_permission_service_ids_${SERVICES[1].id}`).prop('checked')).toEqual(true)

      wrapper.find(`input#user_member_permission_service_ids_${SERVICES[0].id}`).simulate('change')
      expect(wrapper.find(`input#user_member_permission_service_ids_${0}`).prop('checked')).toEqual(false)
      expect(wrapper.find(`input#user_member_permission_service_ids_${1}`).prop('checked')).toEqual(true)
    })
  })

  describe('when "services" checkbox is visible and NOT selected', () => {
    const props = {
      initialState: { role: 'member' as Role, admin_sections: ['partners'] as AdminSection[] },
      services: SERVICES as Api[]
    }

    it('should render AllServicesCheckbox checked', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('input[name="user[member_permission_service_ids]"]').prop('checked')).toEqual(true)
    })

    it('should render all services checked and disabled', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('input[name="user[member_permission_service_ids][]"]')).toHaveLength(SERVICES.length)
      expect(wrapper.find('input[name="user[member_permission_service_ids][]"]').every({ checked: true, disabled: true })).toEqual(true)
    })
  })
})
