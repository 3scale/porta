import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { Brand } from 'Navigation/components/header/Brand'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  accountSettingsLink: 'my-link',
  accountSettingsClass: 'my-class'
}

describe('<Brand/>', () => {
  it('should render', () => {
    const wrapper = shallow(<Brand {...props} />)
    expect(wrapper.exists('.u-header-brand')).toEqual(true)
    expect(wrapper.exists('.Header-logo')).toEqual(true)
    expect(wrapper.exists('#api_selector')).toEqual(true)
  })
})
