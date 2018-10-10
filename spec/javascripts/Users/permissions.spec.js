/** @jsx element */

import $ from 'jquery'
import { dom, element } from 'decca' // eslint-disable-line no-unused-vars

import {
  UserRole,
  Permissions,
  FeatureAccessInput,
  FeatureAccess,
  ServiceFeatureAccess,
  ServiceAccessList,
  AdminSection,
  ServiceAccess,
  Form
} from '../../../app/javascript/src/Users/permissions'

function render (el, context = {}, dispatch) {
  let doc = document.createDocumentFragment()
  let render = dom.createRenderer(doc, dispatch)
  render(el, context)

  return doc.firstChild
}

describe('UserRole', function () {
  it('renders checked', function () {
    let node = render(<UserRole role='admin'/>, { role: 'admin' })

    expect(node).toContainElement('input[name="user[role]"][type=radio][value=admin]:checked')
  })

  it('renders unchecked', function () {
    let node = render(<UserRole role='member'/>, { role: 'admin' })
    expect(node).toContainElement('input[name="user[role]"][type=radio][value=member]:not(:checked)')
  })

  it('has label', function () {
    let node = render(<UserRole role='member' label='Member'/>)

    expect(node).toContainText('Member')
  })

  it('changes state on click', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<UserRole role='member'/>, { role: 'admin' }, dispatch)

    $('#user_role_member', node).change()

    expect(dispatch).toHaveBeenCalledWith({ role: 'member' })
  })
})

describe('Permissions', function () {
  it('is visible for the same role', function () {
    let node = render(<Permissions role='member'/>, { role: 'member' })

    document.body.appendChild(node)

    expect(node).toBeVisible()
  })

  it('is visible for the same role', function () {
    let node = render(<Permissions role='admin'/>, { role: 'member' })

    document.body.appendChild(node)

    expect(node).not.toBeVisible()
  })
})

describe('FeatureAccessInput', function () {
  const noServicePermissionsGranted = 'FeatureAccessList--noServicePermissionsGranted'

  it('toggles no service permissions granted class', function () {
    let list = (sections) => {
      let node = render(<FeatureAccessInput />, { admin_sections: sections })
      return $(node).find('.FeatureAccessList')
    }

    expect(list([])).toHaveClass(noServicePermissionsGranted)
    expect(list(['portal'])).toHaveClass(noServicePermissionsGranted)
    expect(list(['services'])).toHaveClass(noServicePermissionsGranted)
    expect(list(['finance'])).toHaveClass(noServicePermissionsGranted)
    expect(list(['partners'])).not.toHaveClass(noServicePermissionsGranted)
  })

  it('renders children', function () {
    let node = render(<FeatureAccessInput><li id='child'/></FeatureAccessInput>)

    expect(node).toContainElement('ol > li#child')
  })
})

describe('FeatureAccess', function () {
  const isUnchecked = 'is-unchecked'
  const isChecked = 'is-checked'

  it('renders checked', function () {
    let node = render(<FeatureAccess value='portal'/>, { admin_sections: ['plans', 'portal'] })

    expect(node)
      .toContainElement('input[name="user[member_permission_ids][]"][type=checkbox][value=portal]:checked')
    expect(node).toHaveClass(isChecked)
    expect(node).not.toHaveClass(isUnchecked)
  })

  it('renders unchecked', function () {
    let node = render(<FeatureAccess value='plans'/>)

    expect(node)
      .toContainElement('input[name="user[member_permission_ids][]"][type=checkbox][value=plans]:not(:checked)')
    expect(node).toHaveClass(isUnchecked)
    expect(node).not.toHaveClass(isChecked)
  })

  it('has correct class name', function () {
    let node = render(<FeatureAccess value='partners'/>)

    expect(node).toHaveClass('FeatureAccessList-item--partners')
    expect(node).toContainElement('input.user_member_permission_ids--service')

    node = render(<FeatureAccess value='portal'/>)
    expect(node).toHaveClass('FeatureAccessList-item--portal')
    expect(node).not.toContainElement('input.user_member_permission_ids--service')
  })

  it('renders children', function () {
    let node = render(<FeatureAccess>Foobar</FeatureAccess>)

    expect(node).toHaveText('Foobar')
  })

  it('adds section', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<FeatureAccess value='plans'/>, { admin_sections: [] }, dispatch)

    $('#user_member_permission_ids_plans', node).change()
    expect(dispatch).toHaveBeenCalledWith({ admin_sections: ['plans'] })
  })

  it('removes section', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<FeatureAccess value='plans'/>, { admin_sections: ['plans'] }, dispatch)

    $('#user_member_permission_ids_plans', node).change()
    expect(dispatch).toHaveBeenCalledWith({ admin_sections: [] })
  })
})

describe('ServiceFeatureAccess', function () {
  const noServicePermissionsGranted = 'FeatureAccessList--noServicePermissionsGranted'

  it('renders checked', function () {
    let node = render(<ServiceFeatureAccess value='services'/>, { admin_sections: [] })

    expect(node)
      .toContainElement('input[name="user[member_permission_service_ids]"][type=checkbox][value=""]:checked')
  })

  it('renders unchecked', function () {
    let node = render(<ServiceFeatureAccess value='services'/>, { admin_sections: ['services'] })

    expect(node)
      .toContainElement('input[name="user[member_permission_service_ids]"][type=checkbox]:not(:checked)')
  })

  it('has correct class name', function () {
    let node = render(<ServiceFeatureAccess value='services'/>)

    expect(node).toHaveClass('FeatureAccessList-item--services')
    expect(node).toHaveClass(noServicePermissionsGranted)

    node = render(<ServiceFeatureAccess value='services'/>, { admin_sections: ['partners'] })
    expect(node).not.toHaveClass(noServicePermissionsGranted)
  })

  it('renders children', function () {
    let node = render(<ServiceFeatureAccess>Foobar</ServiceFeatureAccess>)

    expect(node).toHaveText('Foobar')
  })

  it('adds section', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<ServiceFeatureAccess value='services'/>, { admin_sections: [] }, dispatch)

    $('#user_member_permission_ids_services', node).change()
    expect(dispatch).toHaveBeenCalledWith({ admin_sections: ['services'] })
  })

  it('removes section', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<ServiceFeatureAccess value='services'/>, { admin_sections: ['services'] }, dispatch)

    $('#user_member_permission_ids_services', node).change()
    expect(dispatch).toHaveBeenCalledWith({ admin_sections: [] })
  })

  it('renders service_ids hidden input if services section has been checked', function () {
    let hiddenInput = 'input[type=hidden][name="user[member_permission_service_ids][]"]'
    let nodeUnchecked = render(<ServiceFeatureAccess value='services'/>, { admin_sections: ['services'] })

    expect(nodeUnchecked).toContainElement(hiddenInput)

    let nodeChecked = render(<ServiceFeatureAccess value='services'/>)

    expect(nodeChecked).not.toContainElement(hiddenInput)
  })
})

describe('ServiceAccessList', function () {
  const noServicePermissionsGranted = 'ServiceAccessList--noServicePermissionsGranted'

  it('toggles no service permissions granted class', function () {
    let list = (sections) => {
      let node = render(<ServiceAccessList />, { admin_sections: sections })
      return $(node).find('.ServiceAccessList')
    }

    expect(list([])).toHaveClass(noServicePermissionsGranted)
    expect(list(['portal'])).toHaveClass(noServicePermissionsGranted)
    expect(list(['services'])).toHaveClass(noServicePermissionsGranted)
    expect(list(['finance'])).toHaveClass(noServicePermissionsGranted)
    expect(list(['partners'])).not.toHaveClass(noServicePermissionsGranted)
  })

  it('renders children', function () {
    let node = render(<ServiceAccessList><li id='child'/></ServiceAccessList>)

    expect(node).toContainElement('ol > li#child')
  })
})

describe('AdminSection', function () {
  const isUnavailable = 'is-unavailable'

  it('renders correct class', function () {
    let node = render(<AdminSection name='portal'/>)

    expect(node).toHaveClass('ServiceAccessList-sectionItem--portal')
  })

  it('is available', function () {
    let node = render(<AdminSection name='portal'/>, { admin_sections: ['portal'] })

    expect(node).not.toHaveClass(isUnavailable)
  })

  it('is available', function () {
    let node = render(<AdminSection name='portal'/>, { admin_sections: ['partners'] })

    expect(node).toHaveClass(isUnavailable)
  })

  it('renders children', function () {
    let node = render(<AdminSection>Foobar</AdminSection>)

    expect(node).toHaveText('Foobar')
  })
})

describe('ServiceAccess', function () {
  const service = { id: 6, name: '3scale Inc.' }

  it('renders name', function () {
    let node = render(<ServiceAccess service={service}/>)

    expect(node).toContainText(service.name)
  })

  it('renders input', function () {
    let node = render(<ServiceAccess service={service}/>)

    expect(node)
      .toContainElement('input[type=checkbox][name="user[member_permission_service_ids][]"][value=6]')
  })

  it('renders disabled', function () {
    let disabled = 'input[disabled]'
    let state = {}
    let node = () => render(<ServiceAccess/>, state)

    // all services are enabled, so individual checkboxes are disabled
    expect(node()).toContainElement(disabled)

    // only some (or none) services are enabled, so nothing is disabled
    state.admin_sections = ['services']
    expect(node()).not.toContainElement(disabled)

    // no services are enabled
    state.member_permission_service_ids = []
    expect(node()).not.toContainElement(disabled)

    state.admin_sections = undefined
    expect(node()).toContainElement(disabled)
  })

  it('renders checked', function () {
    let checked = 'input:checked'
    let state = {}
    let node = () => render(<ServiceAccess service={service}/>, state)

    // all services are enabled
    expect(node()).toContainElement(checked, 'all services enabled - element checked')

    // prerequisite for the following two tests
    state.admin_sections = ['services']

    // no services are enabled
    state.member_permission_service_ids = []
    expect(node()).not.toContainElement(checked, 'no services are enabled - element not checked')

    // only specific services are enabled
    state.member_permission_service_ids.push(service.id)
    expect(node()).toContainElement(checked, 'current service is enabled - element checked')
  })

  it('adds services', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<ServiceAccess service={service}/>, { member_permission_service_ids: [], admin_sections: ['services'] }, dispatch)

    $('.user_member_permission_service_ids', node).change()

    expect(dispatch).toHaveBeenCalledWith({ member_permission_service_ids: [service.id] })
  })

  it('removes services', function () {
    let dispatch = jasmine.createSpy('dispatch')
    let node = render(<ServiceAccess service={service}/>, { member_permission_service_ids: [service.id] }, dispatch)

    $('.user_member_permission_service_ids', node).change()

    expect(dispatch).toHaveBeenCalledWith({ member_permission_service_ids: [] })
  })
})

describe('Form', () => {
  it('render the given features', () => {
    const FEATURES = ['portal', 'finance']
    let node = render(<Form services={[]} features={FEATURES}/>, {})

    expect(node).toContainText('Developer Portal')
    expect(node).toContainElement('input#user_member_permission_ids_portal')
    expect(node).toContainText('Billing')
    expect(node).toContainElement('input#user_member_permission_ids_finance')
    expect(node).not.toContainText('Analytics')
  })
})
