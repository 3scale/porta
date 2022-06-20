// @flow

import * as React from 'react'

import type { Role } from 'Users/types'

const ADMIN_LABEL = 'Admin (full access)'
const MEMBER_LABEL = `Member (limited access, <strong>cannot create new API products  or API backends</strong>)`

/**
 * A radio group to select the user's role: Admin or Member.
 * @param {Role}      selectedRole  - The radio button currently selected.
 * @param {Function}  onRoleChanged - A callback function triggered when the selected value changes.
 */
const RoleRadioGroup = ({ selectedRole, onRoleChanged }: {
  selectedRole: Role,
  onRoleChanged: Role => void
}): React.Node => (
  <li className='radio optional' id='user_role_input'>
    <fieldset>
      <legend className='label'>
        <label>Role</label>
      </legend>
      <ol>
        <UserRole role='admin' label={ADMIN_LABEL} checked={selectedRole === 'admin'} onChange={onRoleChanged}/>
        <UserRole role='member' label={MEMBER_LABEL} checked={selectedRole === 'member'} onChange={onRoleChanged}/>
      </ol>
    </fieldset>
  </li>
)

/**
 * A radio button that represents a user role.
 * @param {Role}      role      - The user role the radio button represents.
 * @param {string}    label     - The value of the radio button.
 * @param {boolean}   checked   - Whether it is selected or not.
 * @param {Function}  onChange  - A callback function triggered when selected.
 */
const UserRole = ({ role, label, checked, onChange }: {
  role: Role,
  label: string,
  checked: boolean,
  onChange: (role: Role) => void
}) => (
  <li>
    <label htmlFor={`user_role_${role}`}>
      <input
        className='roles_ids'
        name='user[role]'
        type='radio'
        id={`user_role_${role}`}
        checked={checked}
        value={role}
        onChange={() => onChange(role) }
      />
      {label}
    </label>
  </li>
)

export { RoleRadioGroup }
