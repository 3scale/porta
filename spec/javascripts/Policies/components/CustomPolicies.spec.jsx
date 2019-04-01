import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { CustomPolicies } from 'Policies/components/CustomPolicies'

Enzyme.configure({ adapter: new Adapter() })

describe('CustomPolicies', () => {
  it('should render input correctly', () => {
    const wrapper = shallow(<CustomPolicies />)
    expect(wrapper.find('section').hasClass('CustomPolicies')).toBe(true)
    expect(wrapper.find('header').hasClass('CustomPolicies-header')).toBe(true)
    expect(wrapper.find('h2').hasClass('CustomPolicies-title')).toBe(true)
    expect(wrapper.find('a.CustomPolicies-addPolicy').text()).toBe(' New Custom Policy Integration')
  })
})
