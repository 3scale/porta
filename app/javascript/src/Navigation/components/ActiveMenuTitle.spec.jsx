import React from 'react'
import Enzyme, { render } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ActiveMenuTitle } from './ActiveMenuTitle'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (activeMenu, currentApi) {
  return render(<ActiveMenuTitle activeMenu={activeMenu} currentApi={currentApi} />)
}

it('should return the proper title depending on the current menu', () => {
  expect(getWrapper('dashboard').text()).toEqual(' Dashboard ')

  expect(getWrapper('personal').text()).toEqual(' Account Settings ')
  expect(getWrapper('account').text()).toEqual(' Account Settings ')

  expect(getWrapper('buyers').text()).toEqual(' Audience ')
  expect(getWrapper('finance').text()).toEqual(' Audience ')
  expect(getWrapper('cms').text()).toEqual(' Audience ')
  expect(getWrapper('site').text()).toEqual(' Audience ')
  expect(getWrapper('settings').text()).toEqual(' Audience ')
  expect(getWrapper('audience').text()).toEqual(' Audience ')

  expect(getWrapper('applications').text()).toEqual(' All APIs ')
  expect(getWrapper('active_docs').text()).toEqual(' All APIs ')

  expect(getWrapper('serviceadmin', { service: { name: 'Test' } }).text())
    .toEqual(' API: Test ')
  expect(getWrapper('monitoring', { service: { name: 'Test' } }).text())
    .toEqual(' API: Test ')
})

it('should return a default title', () => {
  expect(getWrapper().text()).toEqual(' Choose an API ')
})
