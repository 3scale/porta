import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { SessionMenu } from 'Navigation/components/header/SessionMenu'
import { Avatar } from '@patternfly/react-core'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  avatarLinkClass: 'my-class',
  impersonated: 'true',
  accountName: 'account-name',
  displayName: 'display-name',
  logoutPath: 'logout',
  username: 'username'
}

describe('<SessionMenu/>', () => {
  it('renders <SessionMenu/> component when impersonated', () => {
    const wrapper = shallow(<SessionMenu {...props} />)
    expect(wrapper.find('.PopNavigation--session')).toHaveLength(1)
    expect(wrapper.find('a.PopNavigation-trigger')).toHaveLength(1)
    expect(wrapper.find('a.PopNavigation-trigger').hasClass(props.avatarLinkClass)).toEqual(true)
    expect(wrapper.find(Avatar)).toHaveLength(1)
    expect(wrapper.find('.fa-bolt')).toHaveLength(2)
    expect(wrapper.find('.PopNavigation-list')).toHaveLength(1)
    expect(wrapper.find('.PopNavigation-info').text()).toContain('Impersonating a virtual admin user from')
    expect(wrapper.find('.PopNavigation-info').text()).not.toContain('Signed in to')
    expect(wrapper.find('.PopNavigation-info').text()).toContain(props.accountName)
    expect(wrapper.find('.PopNavigation-info').text()).toContain(props.displayName)
    expect(wrapper.find('#sign-out-button').props().href).toEqual(props.logoutPath)
    expect(wrapper.find('.fa-fw')).toHaveLength(1)
  })

  it('renders <SessionMenu/> component when not impersonated', () => {
    const unImpersonatedProps = Object.assign({}, props, { impersonated: null })
    const wrapper = shallow(<SessionMenu {...unImpersonatedProps} />)
    expect(wrapper.find('.fa-bolt')).toHaveLength(0)
    expect(wrapper.find('.PopNavigation-info').text()).not.toContain('Impersonating a virtual admin user from')
    expect(wrapper.find('.PopNavigation-info').text()).toContain('Signed in to')
  })
})
