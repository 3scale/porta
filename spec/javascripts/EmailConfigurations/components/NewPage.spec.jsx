// @flow

import React from 'react'
import { mount } from 'enzyme'

import { NewPage } from 'EmailConfigurations/components/NewPage'

const defaultProps = {
  emailConfiguration: {
    email: '',
    userName: '',
    password: ''
  },
  url: 'p/admin/email_configurations'
}

const mountWrapper = (props) => mount(<NewPage {...{ ...defaultProps, ...props }} />)

it('should render a form', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('EmailConfigurationForm').exists()).toEqual(true)
})
