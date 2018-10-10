/** @jsx element */

import 'core-js/fn/object/assign' // make Object.assign on IE 11
import 'core-js/fn/array/includes'
import {dom, element} from 'decca' // eslint-disable-line no-unused-vars
import classNames from 'classnames'

const Inputs = { // eslint-disable-line no-unused-vars
  render ({props, children}) {
    return (
      <fieldset class='inputs' name={props.name}>
        <legend><span>{props.name}</span></legend>
        <ol>{ children }</ol>
      </fieldset>
    )
  }
}

const RoleInput = { // eslint-disable-line no-unused-vars
  render ({props, children}) {
    return (
      <li class='radio optional' id='user_role_input'>
        <fieldset>
          <legend class='label'><label>Role</label></legend>
          <ol>{ children }</ol>
        </fieldset>
      </li>
    )
  }
}

export const UserRole = {
  render ({props, context = {}, dispatch}) {
    let { role, label } = props

    let change = () => {
      dispatch({role: role})
    }

    return (
      <li>
        <label for={`user_role_${role}`}>
          <input class='roles_ids' name='user[role]' type='radio'
                 id={`user_role_${role}`} checked={ role === context.role }
                 value={role} onChange={ change } />{' '}{ label }</label>
      </li>
    )
  }
}

export const Permissions = { // eslint-disable-line no-unused-vars
  render ({ props, context, children }) {
    return (
      <li class='radio optional' id='user_member_permissions_input'
          style={{ display: context.role === props.role ? 'block' : 'none' }}>
        { children }
      </li>
    )
  }
}

export const FeatureAccessInput = { // eslint-disable-line no-unused-vars
  render ({ children, context }) {
    let olClass = classNames('FeatureAccessList',
      {'FeatureAccessList--noServicePermissionsGranted': !servicePermissionsGranted(context)})

    return (
      <fieldset>
        <legend class='label'><label>This user can access</label></legend>
        <ol class={olClass}>{ children }</ol>
      </fieldset>
    )
  }
}

function servicePermissionsGranted (context) {
  let sections = context.admin_sections || []
  return SERVICE_PERMISSIONS.filter(section => sections.includes(section)).length > 0
}

export const FeatureAccess = { // eslint-disable-line no-unused-vars
  render ({props, children, context, dispatch}) {
    let { value } = props
    let sections = new Set(context.admin_sections)

    let checked = sections.has(value)

    let toggle = () => {
      sections[checked ? 'delete' : 'add'](value)
      let state = { admin_sections: [...sections] }

      return dispatch(state)
    }

    let liClass = classNames(
      `FeatureAccessList-item FeatureAccessList-item--${value}`,
      { 'is-unchecked': !checked, 'is-checked': checked }
    )

    let inputClass = classNames('user_member_permission_ids',
      { 'user_member_permission_ids--service': SERVICE_PERMISSIONS.includes(value) })

    return (
      <li class={liClass}>
        <label for={`user_member_permission_ids_${value}`}>
          <input class={inputClass} name='user[member_permission_ids][]'
                 id={`user_member_permission_ids_${value}`} value={value}
                 type='checkbox' checked={ checked }
                 onChange={ toggle }
          />{ children }
        </label>
      </li>
    )
  }
}

export const ServiceFeatureAccess = { // eslint-disable-line no-unused-vars
  render ({props, children, context, dispatch}) {
    let { value } = props
    let sections = new Set(context.admin_sections)
    let checked = !sections.has(value)

    let change = () => {
      sections[checked ? 'add' : 'delete'](value)
      let state = { admin_sections: [...sections] }

      return dispatch(state)
    }

    let liClass = classNames(`FeatureAccessList-item FeatureAccessList-item--${value}`,
      { 'FeatureAccessList--noServicePermissionsGranted': !servicePermissionsGranted(context) })

    // if service feature access checkbox is unchecked
    // at least blank service_ids array has to be sent
    let blankServiceIdsInput = !checked ? <input type='hidden' name='user[member_permission_service_ids][]' /> : null

    return (
      <li class={liClass}>
        <label for={`user_member_permission_ids_${value}`}>
          <input class='user_member_permission_ids' name='user[member_permission_service_ids]'
                 id={`user_member_permission_ids_${value}`} attributes={{value: ''}}
                 type='checkbox' checked={ checked }
                 onChange={ change }
          />{ children }
        </label>
        { blankServiceIdsInput }
      </li>
    )
  }
}

const SERVICE_PERMISSIONS = ['partners', 'monitoring', 'plans']

export const ServiceAccessList = { // eslint-disable-line no-unused-vars
  render ({children, context}) {
    let olClass = classNames('ServiceAccessList',
      { 'ServiceAccessList--noServicePermissionsGranted': !servicePermissionsGranted(context) })

    return (
      <fieldset>
        <ol class={olClass}>
          { children }
        </ol>
      </fieldset>
    )
  }
}

export const AdminSection = { // eslint-disable-line no-unused-vars
  render ({props, children, context}) {
    let sections = new Set(context.admin_sections)
    let { name } = props
    let available = sections.has(name)

    return (
      <li class={classNames(`ServiceAccessList-sectionItem ServiceAccessList-sectionItem--${name}`, { 'is-unavailable': !available })}>
        { children }
      </li>
    )
  }
}

export const ServiceAccess = { // eslint-disable-line no-unused-vars
  render ({props, context, dispatch}) {
    let { id, name } = props.service || {}
    let all = !(new Set(context.admin_sections)).has('services')
    let ids = context.member_permission_service_ids || []

    let checked = all || ids.includes(id)
    let disabled = all

    let toggle = () => {
      let services = new Set(ids)
      services[checked ? 'delete' : 'add'](id)
      let state = { member_permission_service_ids: [...services] }

      return dispatch(state)
    }

    return (
      <li class='ServiceAccessList-item'>
        <label class='ServiceAccessList-label is-checked'
               for={`user_member_permission_service_ids_${id}`}>
          <input class='user_member_permission_service_ids'
                 id={`user_member_permission_service_ids_${id}`}
                 name='user[member_permission_service_ids][]' type='checkbox' value={id}
                 checked={ checked } disabled={ disabled } onChange={toggle}/>
          <span class='ServiceAccessList-labelText'>&nbsp;{ name }</span>
        </label>
        <ul class='ServiceAccessList-sections'>
          <AdminSection name='plans'>Integration & Application Plans</AdminSection>
          <AdminSection name='monitoring'>Analytics</AdminSection>
          <AdminSection name='partners'>Applications</AdminSection>
        </ul>
      </li>
    )
  }
}

export const Form = { // eslint-disable-line no-unused-vars
  render ({ props }) {
    let { services, features } = props
    const FEATURE_NAMES = {
      portal: 'Developer Portal',
      finance: 'Billing',
      settings: 'Settings',
      partners: 'Developer Accounts -- Applications',
      monitoring: 'Analytics',
      plans: 'Integration & Application Plans'
    }
    return (
      <Inputs name='Administrative'>
        <RoleInput>
          <UserRole role='admin' label='Admin (full access)'/>
          <UserRole role='member' label='Member'/>
        </RoleInput>

        <Permissions role='member'>
          <FeatureAccessInput role='member'>

            <input type='hidden' name='user[member_permission_ids][]' />
            {features.map(feature => <FeatureAccess value={feature}>&nbsp;{FEATURE_NAMES[feature]}</FeatureAccess>)}
            <ServiceFeatureAccess value='services'> All current and future APIs</ServiceFeatureAccess>
          </FeatureAccessInput>

          <ServiceAccessList>
            {services.map(service => <ServiceAccess service={service}/>)}
          </ServiceAccessList>
        </Permissions>
      </Inputs>
    )
  }
}

let initialState = { }

export function render ({el, state = initialState, services = [], features = []}) {
  let render = dom.createRenderer(el, dispatch)

  let rendering = false

  function dispatch (newState = {}) {
    state = Object.assign({}, state, newState)

    if (!rendering) {
      rendering = true
      try {
        render(<Form services={services} features={features}/>, state)
      } finally {
        rendering = false
      }
    } else {
      console.error('already rendering!')
    }
  }

  dispatch()
}
