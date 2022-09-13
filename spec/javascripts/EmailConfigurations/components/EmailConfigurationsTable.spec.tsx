import React from 'react'
import { mount } from 'enzyme'

import { EmailConfigurationsTable } from 'EmailConfigurations/components/EmailConfigurationsTable'

const defaultProps = {
  emailConfigurations: [],
  emailConfigurationsCount: 0,
  newEmailConfigurationPath: 'p/admin/email_configurations/new'
} as const

const mountWrapper = (props: undefined) => mount(<EmailConfigurationsTable {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
