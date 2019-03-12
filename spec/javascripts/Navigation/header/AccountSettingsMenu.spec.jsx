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
  it('renders <AccountSettingsMenu/> component', () => {
    const wrapper = shallow(<AccountSettingsMenu {...props} />)
    expect(wrapper.find('.PopNavigation--account')).toHaveLength(1)
    expect(wrapper.find('a')).toHaveLength(1)
    expect(wrapper.find('.PopNavigation-trigger').hasClass(props.accountSettingsClass)).toEqual(true)
    expect(wrapper.find('a').props().href).toEqual(props.accountSettingsLink)
  })
})
