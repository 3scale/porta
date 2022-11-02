import { mount } from 'enzyme'

import { EditPage } from 'EmailConfigurations/components/EditPage'

import type { Props } from 'EmailConfigurations/components/EditPage'

const defaultProps = {
  emailConfiguration: {
    email: '',
    userName: '',
    password: ''
  },
  url: 'p/admin/email_configurations'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<EditPage {...{ ...defaultProps, ...props }} />)

it('should render a form', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('EmailConfigurationForm')).toEqual(true)
})

it('should be possible to update the email config, but not by default', () => {
  const wrapper = mountWrapper()
  const submitButton = wrapper.find('.pf-c-button.pf-m-primary[type="submit"]')

  expect(submitButton.exists()).toEqual(true)
  expect(submitButton.props().disabled).toEqual(true)
})

it('should be possible to delete the email config', () => {
  const wrapper = mountWrapper()
  const deleteButton = wrapper.find('.pf-c-button.pf-m-danger')

  expect(deleteButton.exists()).toEqual(true)
  expect(deleteButton.props().disabled).toEqual(false)
})
