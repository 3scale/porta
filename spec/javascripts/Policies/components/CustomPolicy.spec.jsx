import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {
  CustomPolicy,
  CustomPolicyEditor,
  CustomPolicyForm,
  POLICY_TEMPLATE
} from 'Policies/components/CustomPolicy'

Enzyme.configure({ adapter: new Adapter() })

describe('CustomPolicy', () => {
  it('should render itself correctly', () => {
    const wrapper = shallow(<CustomPolicy />)
    expect(wrapper.find('section').hasClass('CustomPolicy')).toBe(true)
    expect(wrapper.find('header').hasClass('CustomPolicy-header')).toBe(true)
    expect(wrapper.find('a').hasClass('CustomPolicy-cancel')).toBe(true)
    expect(wrapper.find('CustomPolicyEditor').prop('initialPolicy')).toBe(POLICY_TEMPLATE)
  })
})

describe('CustomPolicyEditor', () => {
  it('should render itself correctly', () => {
    const wrapper = shallow(<CustomPolicyEditor initialPolicy={POLICY_TEMPLATE} />)
    expect(wrapper.find('SchemaEditor').exists()).toBe(true)
    expect(wrapper.find('Form').exists()).toBe(true)
    expect(wrapper.find('.PolicyConfiguration-name').text()).toBe('Name of the custom policy')
    expect(wrapper.find('.PolicyConfiguration-version').text()).toBe('0.0.1')
    expect(wrapper.find('.PolicyConfiguration-summary').text()).toBe('A one-line (less than 75 characters) summary of what this custom policy does.')
    expect(wrapper.find('.PolicyConfiguration-description').text()).toBe('A complete description of what this custom policy does.')
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
  it.skip('should change submit method when clicking Delete Policy before submitting the form', () => {
    const mockedWindow = { confirm: jest.fn(() => true) }
    const {wrapper} = setup({win: mockedWindow})
    const submitMethod = wrapper.find('input[name="_method"]')

    expect(submitMethod.prop('value')).toBe('put')

    const deleteButton = wrapper.find('input[value="Delete Policy"]')
    deleteButton.simulate('click')

    wrapper.update()
    // TODO: assert before submission
    expect(wrapper.find('input[name="_method"]').prop('value')).toBe('delete')
  })
})
