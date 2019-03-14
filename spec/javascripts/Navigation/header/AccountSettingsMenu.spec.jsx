import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { AccountSettingsMenu } from 'Navigation/components/header/AccountSettingsMenu'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  accountSettingsLink: 'my-link',
  accountSettingsClass: 'my-class'
}

describe('<AccountSettingsMenu/>', () => {
  it('should render with right props', () => {
    const wrapper = shallow(<AccountSettingsMenu {...props} />)
    expect(wrapper.exists('.PopNavigation--account')).toEqual(true)
    expect(wrapper.find('.PopNavigation-trigger').hasClass(props.accountSettingsClass)).toEqual(true)
    expect(wrapper.find('a').props().href).toEqual(props.accountSettingsLink)
  })
})
