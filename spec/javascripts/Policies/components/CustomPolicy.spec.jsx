import React from 'react'
import Enzyme, { mount, shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import {JSDOM} from 'jsdom'

import {
  CustomPolicy,
  CustomPolicyForm,
  CSRFToken,
  POLICY_TEMPLATE
} from 'Policies/components/CustomPolicy'

Enzyme.configure({ adapter: new Adapter() })

describe('CustomPolicy', () => {
  it('should render itself correctly', () => {
    const wrapper = shallow(<CustomPolicy />)
    expect(wrapper.find('section').hasClass('CustomPolicy')).toBe(true)
    expect(wrapper.find('header').hasClass('CustomPolicy-header')).toBe(true)
    expect(wrapper.find('h2').hasClass('CustomPolicy-title')).toBe(true)
    expect(wrapper.find('a').hasClass('CustomPolicy-cancel')).toBe(true)
    expect(wrapper.find('Form').prop('initialPolicy')).toBe(POLICY_TEMPLATE)
  })
})

describe('CustomPolicyForm', () => {
  function setup (customProps) {
    const policy = {
      schema: {
        $schema: 'http://someswonderfulschemaspec.com/v2#7',
        name: 'awesomeness',
        version: '4.2.0',
        description: 'Adds awesomeness to your proxy. Period.',
        summary: 'Adds awesomeness to your proxy.',
        configuration: {awesome: true}
      },
      id: 42,
      directory: 'theanswer'
    }
    const props = {
      ...{
        policy,
        onChange: jest.fn()
      },
      ...customProps
    }

    const wrapper = shallow(<CustomPolicyForm {...props} />)

    return {wrapper, props}
  }

  it('should render correct the edit policy form', () => {
    const {wrapper, props} = setup({})
    expect(wrapper.find('form').prop('action')).toBe('/p/admin/registry/policies/42')
    expect(wrapper.find('input[name="schema"]').prop('value')).toBe(JSON.stringify(props.policy.schema))
    expect(wrapper.find('input[name="_method"]').exists()).toBe(true)
  })

  it('should render correct the new policy form', () => {
    const {wrapper} = setup({policy: POLICY_TEMPLATE})
    expect(wrapper.find('form').prop('action')).toBe('/p/admin/registry/policies/')
    expect(wrapper.find('input[name="schema"]').prop('value')).toBe(JSON.stringify(POLICY_TEMPLATE.schema))
    expect(wrapper.find('input[name="_method"]').exists()).toBe(false)
  })
})

describe('CSRFToken', () => {
  function setup () {
    const jsdom = new JSDOM(
      `<!doctype html><html>
         <head><meta name="csrf-param" content="authenticity_token"><meta name="csrf-token" content="=42="></head>
         <body></body>
       </html>`
    )
    const { window } = jsdom
    return mount(<CSRFToken win={window} />)
  }

  it('should render itself correctly', () => {
    const wrapper = setup()
    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBe('authenticity_token')
    expect(wrapper.find('input').prop('value')).toBe('=42=')
  })
})
