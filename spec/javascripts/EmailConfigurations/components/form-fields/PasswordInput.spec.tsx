import { mount } from 'enzyme'

import { PasswordInput } from 'EmailConfigurations/components/form-fields/PasswordInput'

import type { Props } from 'EmailConfigurations/components/form-fields/PasswordInput'

const setPassword = jest.fn()
const defaultProps = {
  password: '',
  setPassword,
  errors: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PasswordInput {...{ ...defaultProps, ...props }} />)

beforeEach(() => setPassword.mockReset())

it('should work', () => {
  const value = '$DragonHeartsstring1909'
  const wrapper = mountWrapper()

  const input = wrapper.find('input[name="email_configuration[password]"]')
  input.simulate('change', { currentTarget: { value } })

  expect(setPassword).toHaveBeenCalledTimes(1)
})

it('should render errors', () => {
  const errors = ['Wrong this', 'Wrong that']
  const wrapper = mountWrapper({ errors })

  expect(wrapper.find('.pf-m-error').text()).toEqual('Wrong this,Wrong that')
})
