import React from 'react'
import Enzyme, { mount, shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import {JSDOM} from 'jsdom'
import { UnControlled as CodeMirror } from 'react-codemirror2'

import {
  CustomPolicy,
  CustomPolicyForm,
  FormInput,
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
    expect(wrapper.find('Form').prop('policy')).toBe(POLICY_TEMPLATE)
  })
})

describe('CustomPolicyForm', () => {
  function setup (customProps) {
    const policy = {
      $schema: 'http://someswonderfulschemaspec.com/v2#7',
      name: 'awesomeness',
      version: '4.2.0',
      description: 'Adds awesomeness to your proxy. Period.',
      summary: 'Adds awesomeness to your proxy.',
      configuration: {awesome: true},
      humanName: 'Pure Awesomeness Policy'
    }
    const props = {
      ...{
        policy,
        onChange: jest.fn(),
        isNewPolicy: false
      },
      ...customProps
    }

    return shallow(<CustomPolicyForm {...props} />)
  }

  it('should render correct the edit policy form', () => {
    const wrapper = setup({})
    expect(wrapper.find('form').prop('action')).toBe('/p/admin/registry/policies/awesomeness-4.2.0')
    expect(wrapper.find('input[name="configuration"]').prop('value')).toBe('{"awesome":true}')
    expect(wrapper.find('input[name="_method"]').exists()).toBe(true)
  })

  it('should render correct the new policy form', () => {
    const wrapper = setup({policy: POLICY_TEMPLATE, isNewPolicy: true})
    expect(wrapper.find('form').prop('action')).toBe('/p/admin/registry/policies/')
    expect(wrapper.find('input[name="configuration"]').prop('value')).toBe('{}')
    expect(wrapper.find('input[name="_method"]').exists()).toBe(false)
  })
})

describe('FormInput', () => {
  function mountComponent (props) {
    return mount(<FormInput {...props} />)
  }

  it('should render input correctly', () => {
    const props = {
      humanname: 'Version',
      name: 'version',
      value: '4.2.0',
      type: 'text',
      disabled: true,
      onChange: jest.fn()
    }
    const wrapper = mountComponent(props)
    expect(wrapper.find(FormInput).exists()).toBe(true)
    expect(wrapper.find('label').text()).toBe('Version:')
    expect(wrapper.find('input').prop('type')).toBe('text')
    expect(wrapper.find('input').prop('name')).toBe('version')
    expect(wrapper.find('input').prop('value')).toBe('4.2.0')
    expect(wrapper.find('input').prop('disabled')).toBe(true)
  })

  it('should render input correctly', () => {
    const props = {
      humanname: 'Summary',
      name: 'summary',
      value: 'A very classic textarea.',
      type: 'textarea',
      disabled: false,
      onChange: jest.fn()
    }
    const wrapper = mountComponent(props)
    expect(wrapper.find(FormInput).exists()).toBe(true)
    expect(wrapper.find('label').text()).toBe('Summary:A very classic textarea.')
    expect(wrapper.find('textarea').prop('name')).toBe('summary')
    expect(wrapper.find('textarea').prop('value')).toBe('A very classic textarea.')
    expect(wrapper.find('textarea').prop('disabled')).toBe(false)
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
