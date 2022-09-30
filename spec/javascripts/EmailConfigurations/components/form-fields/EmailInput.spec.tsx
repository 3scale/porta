import { mount } from 'enzyme'

import { EmailInput, Props } from 'EmailConfigurations/components/form-fields/EmailInput'

const setEmail = jest.fn()
const defaultProps = {
  email: '',
  setEmail,
  errors: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<EmailInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should work', () => {
  const value = 'hello@ollivanders.co.uk'
  const wrapper = mountWrapper()

  const input = wrapper.find('input[name="email_configuration[email]"]')
  input.simulate('change', { currentTarget: { value } })

  expect(setEmail).toHaveBeenCalledTimes(1)
})

it('should render errors', () => {
  const errors = ['Error A', 'Error B']
  const wrapper = mountWrapper({ errors })

  expect(wrapper.find('.pf-m-error').text()).toEqual('Error A,Error B')
})
