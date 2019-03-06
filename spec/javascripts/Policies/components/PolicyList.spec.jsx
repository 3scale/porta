import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { PolicyList, policyEditLink, navigateToEditPolicy } from 'Policies/components/PolicyList'

Enzyme.configure({ adapter: new Adapter() })

let mockedWindow = {
  location: {
    href: '/'
  },
  history: {
    pushState: jest.fn()
  }
}

function mountWrapper () {
  const policies = [
    {name: 'cors', humanName: 'CORS', summary: 'CORS', version: '1.0.0', schema: {}},
    {name: 'echo', humanName: 'Echo', summary: 'Echo', version: '1.0.0', schema: {}}
  ]

  return mount(<PolicyList policies={policies} />)
}

it('should render itself correctly', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(PolicyList).exists()).toBe(true)
  expect(wrapper.find('.Policy').length).toBe(2)
})

it('should create the correct edit link', () => {
  expect(policyEditLink('answer', '42')).toBe('/p/admin/registry/policies/answer-42/edit')
})

it('should navigate to the edit link', () => {
  const url = '/p/admin/registry/policies/answer-42/edit'
  navigateToEditPolicy(url, mockedWindow)
  expect(mockedWindow.location.href).toBe(url)
  console.log(JSON.stringify(mockedWindow.history))
  expect(mockedWindow.history.pushState.mock.calls[0][2]).toBe(url)
})
