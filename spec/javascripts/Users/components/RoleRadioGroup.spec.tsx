import { mount } from 'enzyme'

import { RoleRadioGroup } from 'Users/components/RoleRadioGroup'

import type { Props } from 'Users/components/RoleRadioGroup'
import type { Role } from 'Users/types'

const defaultProps: Props = { selectedRole: 'member', onRoleChanged: jest.fn() }
const mountWrapper = (props: Partial<Props> = {}) => mount(<RoleRadioGroup {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(RoleRadioGroup)).toEqual(true)
})

const ROLES = ['member', 'admin']

it('should render a radio button for each Role', () => {
  const wrapper = mountWrapper()
  expect(ROLES.every(r => wrapper.exists(`input[value="${r}"][name="user[role]"]`))).toEqual(true)
})

it('should render the selected role', () => {
  const selectedRole: Role = 'admin'
  const wrapper = mountWrapper({ selectedRole })

  expect(wrapper.find(`input[value="${selectedRole}"]`).prop('checked')).toEqual(true)
})

it('should call onChanged event with the proper value', () => {
  const onRoleChanged = jest.fn()
  const wrapper = mountWrapper({ onRoleChanged })

  wrapper.find('input#user_role_admin').simulate('change')
  expect(onRoleChanged).toHaveBeenCalledWith('admin')

  wrapper.find('input#user_role_member').simulate('change')
  expect(onRoleChanged).toHaveBeenCalledWith('member')
})
