import { mount } from 'enzyme'

import { UserNameInput } from 'EmailConfigurations/components/form-fields/UserNameInput'

import type { Props } from 'EmailConfigurations/components/form-fields/UserNameInput'

const setUserName = jest.fn()
const defaultProps = {
  userName: '',
  setUserName,
  errors: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<UserNameInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should work', () => {
  const value = 'ollivanders_wands'
  const wrapper = mountWrapper()

  const input = wrapper.find('input[name="email_configuration[user_name]"]')
  input.simulate('change', { currentTarget: { value } })

  expect(setUserName).toHaveBeenCalledTimes(1)
})

it('should render errors', () => {
  const errors = ['Wrong this', 'Wrong that']
  const wrapper = mountWrapper({ errors })

  expect(wrapper.find('.pf-m-error').text()).toEqual('Wrong this,Wrong that')
})
