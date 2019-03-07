import React from 'react'
import Enzyme, { mount, shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import {JSDOM} from 'jsdom'
import { UnControlled as CodeMirror } from 'react-codemirror2'

import {
  CustomPolicy,
  CustomPolicyForm,
  Editor,
  CSRFToken,
  CM_OPTIONS,
  POLICY_TEMPLATE
} from 'Policies/components/CustomPolicy'

Enzyme.configure({ adapter: new Adapter() })

describe('CustomPolicy', () => {
  it('should render input correctly', () => {
    const wrapper = shallow(<CustomPolicy />)
    expect(wrapper.find('section').hasClass('CustomPolicy')).toBe(true)
    expect(wrapper.find('header').hasClass('CustomPolicy-header')).toBe(true)
    expect(wrapper.find('h2').hasClass('CustomPolicy-title')).toBe(true)
    expect(wrapper.find('a').hasClass('CustomPolicy-cancel')).toBe(true)
    expect(wrapper.find('Form').prop('policy')).toBe(POLICY_TEMPLATE)
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

describe('Editor', () => {
  function setup () {
    const onChange = jest.fn()
    // Needed because of https://github.com/scniro/react-codemirror2/issues/23
    global.document = new JSDOM('<!doctype html><html><body></body></html>')
    global.document.body.createTextRange = function () {
      return {
        setEnd: jest.fn(),
        setStart: jest.fn(),
        getBoundingClientRect: jest.fn(),
        getClientRects: () => jest.fn(() => {
          return { length: 0, left: 0, right: 0 }
        })
      }
    }

    const props = {
      onChange,
      code: { type: 'epic' }
    }

    const wrapper = mount(<Editor {...props} />)

    return {wrapper, props, onChange}
  }

  it('should render itself correctly', () => {
    const {wrapper} = setup()
    expect(wrapper.find(Editor).exists()).toBe(true)
    const codeMirror = wrapper.find(CodeMirror)
    expect(codeMirror.exists()).toBe(true)
    expect(codeMirror.prop('value')).toBe('{\n  "type": "epic"\n}')
    expect(codeMirror.prop('autoCursor')).toBe(false)
    expect(codeMirror.prop('options')).toBe(CM_OPTIONS)
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
