import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { JSDOM } from 'jsdom'
import { UnControlled as CodeMirror } from 'react-codemirror2'

import {
  SchemaEditor,
  CM_OPTIONS
} from 'Policies/components/SchemaEditor'

Enzyme.configure({ adapter: new Adapter() })

describe('PolicyEditor', () => {
  function setup (customProps) {
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
      ...{
        onChange,
        schema: {
          '$schema': 'http://apicast.io/policy-v1/schema#manifest',
          'name': 'Epic',
          'summary': 'Epic summary',
          'description': 'Epic description',
          'version': 'builtin',
          'configuration': {}
        }
      },
      ...customProps
    }

    const wrapper = mount(<SchemaEditor {...props} />)

    return {wrapper, props}
  }

  it('should render itself correctly', () => {
    const {wrapper} = setup()
    expect(wrapper.find(SchemaEditor).exists()).toBe(true)
    const codeMirror = wrapper.find(CodeMirror)
    expect(codeMirror.exists()).toBe(true)
    expect(codeMirror.prop('value')).toBe('{\n' +
    '  "$schema": "http://apicast.io/policy-v1/schema#manifest",\n' +
    '  "name": "Epic",\n' +
    '  "summary": "Epic summary",\n' +
    '  "description": "Epic description",\n' +
    '  "version": "builtin",\n' +
    '  "configuration": {}\n' +
    '}')
    expect(codeMirror.prop('autoCursor')).toBe(false)
    expect(codeMirror.prop('options')).toBe(CM_OPTIONS)
  })

  it('should render the correct validation errors', () => {
    const schema = {
      $schema: 'http://apicast.io/policy-v1/schema#manifest',
      summary: 'Epic summary',
      description: 'Epic description',
      version: 'builtin',
      configuration: { }
    }
    const {wrapper} = setup({schema})
    const errorMessages = wrapper.find('ul').find('li')

    expect(errorMessages.length).toBe(1)
    expect(errorMessages.text()).toBe('should have required property \'name\'')
  })
})
