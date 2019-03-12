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
  it('renders <Brand/> component', () => {
    const wrapper = shallow(<Brand {...props} />)
    expect(wrapper.find('.u-header-brand')).toHaveLength(1)
    expect(wrapper.find('.Header-logo')).toHaveLength(1)
    expect(wrapper.find('#api_selector')).toHaveLength(1)
  })
})
