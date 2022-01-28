// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IndexPage } from 'EmailConfigurations/components/IndexPage'

const defaultProps = {
  emailConfigurations: [],
  emailConfigurationsCount: 0,
  newEmailConfigurationPath: ''
}

const mountWrapper = (props) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a button to create a new email configuration', () => {
  const path = 'p/admin/email_configurations/new'
  const wrapper = mountWrapper({ path })
  expect(wrapper.find(`a[href="${path}"]`).exists())
})

describe('when there are no email configurations', () => {
  it.todo('should show a no items yet, create one message')
})

describe('when there are email configurations', () => {
  const emailConfigurations = [{ id: 0, userName: 'ollivanders_wands', email: 'hello@ollivanders.co.uk', links: { edit: '/edit' } }]
  const props = { emailConfigurations, emailConfigurationsCount: emailConfigurations.length }

  it('should show a table with Email and Username', () => {
    const wrapper = mountWrapper(props)
    const row = wrapper.find('.pf-c-table tbody tr')
    expect(row.length).toEqual(emailConfigurations.length)
    expect(row.find('[data-label="Email"]').first().text()).toMatch(emailConfigurations[0].email)
    expect(row.find('[data-label="UserName"]').first().text()).toMatch(emailConfigurations[0].userName)
  })

  it.todo('should be able to filter by ...')
  it.todo('should show a no match found when search result is empty')
})
