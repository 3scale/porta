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
  it('should render with right props', () => {
    const wrapper = shallow(<SessionMenu {...props} />)
    expect(wrapper.exists('.PopNavigation--session')).toEqual(true)
    expect(wrapper.exists('a.PopNavigation-trigger')).toEqual(true)
    expect(wrapper.find('a.PopNavigation-trigger').hasClass(props.avatarLinkClass)).toEqual(true)
    expect(wrapper.find('.PopNavigation-info').text()).toContain(props.accountName)
    expect(wrapper.find('.PopNavigation-info').text()).toContain(props.displayName)
    expect(wrapper.find('#sign-out-button').props().href).toEqual(props.logoutPath)
    expect(wrapper.find('#sign-out-button').props().title).toContain(props.username)
    expect(wrapper.exists('.fa-fw')).toEqual(true)
  })

  it('should display proper message and two `fa-bolt` icons when impersonated', () => {
    const wrapper = shallow(<SessionMenu {...props} />)
    expect(wrapper.find('.fa-bolt')).toHaveLength(2)
    expect(wrapper.find('.PopNavigation-info').text()).toContain('Impersonating a virtual admin user from')
    expect(wrapper.find('.PopNavigation-info').text()).not.toContain('Signed in to')
  })

  it('should display proper message and not any `fa-bolt` icon when not impersonated', () => {
    const unImpersonatedProps = Object.assign({}, props, { impersonated: null })
    const wrapper = shallow(<SessionMenu {...unImpersonatedProps} />)
    expect(wrapper.find('.fa-bolt')).toHaveLength(0)
    expect(wrapper.find('.PopNavigation-info').text()).not.toContain('Impersonating a virtual admin user from')
    expect(wrapper.find('.PopNavigation-info').text()).toContain('Signed in to')
  })
  it('should render one <Avatar/> component', () => {
    const wrapper = shallow(<SessionMenu {...props} />)
    expect(wrapper.exists(Avatar)).toEqual(true)
  })
})
