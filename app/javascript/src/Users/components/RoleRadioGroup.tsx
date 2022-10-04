/* eslint-disable react/no-multi-comp */
import ReactHtmlParser from 'react-html-parser'

import type { Role } from 'Users/types'

const ADMIN_LABEL = 'Admin (full access)'
const MEMBER_LABEL = `Member (limited access, <strong>cannot create new API products  or API backends</strong>)`

/**
 * A radio group to select the user's role: Admin or Member.
 * @param {Role}      selectedRole  - The radio button currently selected.
 * @param {Function}  onRoleChanged - A callback function triggered when the selected value changes.
 */
type Props = {
  selectedRole: Role,
  onRoleChanged: (arg1: Role) => void
}

const RoleRadioGroup: React.FunctionComponent<Props> = ({
  selectedRole,
  onRoleChanged
}) => (
  <li className='radio optional' id='user_role_input'>
    <fieldset>
      <legend className='label'>
        <label>Role</label>
      </legend>
      <ol>
        <UserRole checked={selectedRole === 'admin'} label={ADMIN_LABEL} role='admin' onChange={onRoleChanged} />
        <UserRole checked={selectedRole === 'member'} label={MEMBER_LABEL} role='member' onChange={onRoleChanged} />
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
type UserRoleProps = {
  role: Role,
  label: string,
  checked: boolean,
  onChange: (role: Role) => void
}

const UserRole: React.FunctionComponent<UserRoleProps> = ({
  role,
  label,
  checked,
  onChange
}) => (
  <li>
    <label htmlFor={`user_role_${role}`}>
      <input
        checked={checked}
        className='roles_ids'
        id={`user_role_${role}`}
        name='user[role]'
        type='radio'
        value={role}
        onChange={() => onChange(role)}
      />
      { ReactHtmlParser(label) }
    </label>
  </li>
)

export { RoleRadioGroup, Props }
