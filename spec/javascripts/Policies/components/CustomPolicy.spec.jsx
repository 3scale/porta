import React from 'react'
import Enzyme, { mount, shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import {JSDOM} from 'jsdom'

import {
  CustomPolicy,
  CustomPolicyEditor,
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
    expect(wrapper.find('CustomPolicyEditor').prop('initialPolicy')).toBe(POLICY_TEMPLATE)
  })
})

describe('CustomPolicyEditor', () => {
  it('should render itself correctly', () => {
    const wrapper = shallow(<CustomPolicyEditor initialPolicy={POLICY_TEMPLATE} />)
    expect(wrapper.find('SchemaEditor').exists()).toBe(true)
    expect(wrapper.find('Form').exists()).toBe(true)
    expect(wrapper.find('.PolicyConfiguration-name').text()).toBe('Name of the policy')
    expect(wrapper.find('.PolicyConfiguration-version').text()).toBe('0.0.1')
    expect(wrapper.find('.PolicyConfiguration-summary').text()).toBe('A one-line (less than 75 characters) summary of what this policy does.')
    expect(wrapper.find('.PolicyConfiguration-description').text()).toBe('A complete description of what this policy does.')
  })
})

describe('CustomPolicyForm', () => {
  function setup (customProps = {}) {
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
    const {wrapper, props} = setup()
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

  // TODO: remove `skip` when this is merged: https://github.com/airbnb/enzyme/pull/2008
  it.skip('should change submit method when clicking Delete Policy', () => {
    const {wrapper} = setup()
    const submitMethod = wrapper.find('input[name="_method"]')

    expect(submitMethod.prop('value')).toBe('put')

    const deleteButton = wrapper.find('input[value="Delete Policy"]')
    deleteButton.simulate('click')

    wrapper.update()

    expect(wrapper.find('input[name="_method"]').prop('value')).toBe('delete')
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
