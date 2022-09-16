import React from 'react'
import { mount } from 'enzyme'

import { EmailConfigurationsTable, Props } from 'EmailConfigurations/components/EmailConfigurationsTable'

const defaultProps = {
  emailConfigurations: [],
  emailConfigurationsCount: 0,
  newEmailConfigurationPath: 'p/admin/email_configurations/new'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<EmailConfigurationsTable {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
