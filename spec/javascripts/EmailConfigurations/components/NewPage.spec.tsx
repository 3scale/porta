import { mount } from 'enzyme'

import { NewPage } from 'EmailConfigurations/components/NewPage'

import type { Props } from 'EmailConfigurations/components/NewPage'

const defaultProps = {
  emailConfiguration: {
    email: '',
    userName: '',
    password: ''
  },
  url: 'p/admin/email_configurations'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NewPage {...{ ...defaultProps, ...props }} />)

it('should render a form', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('EmailConfigurationForm')).toEqual(true)
})

it('should render submit button disabled', () => {
  const wrapper = mountWrapper()
  const submitButton = wrapper.find('.pf-c-button.pf-m-primary[type="submit"]')

  expect(submitButton.exists()).toEqual(true)
  expect(submitButton.props().disabled).toEqual(true)
})
