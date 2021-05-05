// @flow

import React from 'react'
import { mount } from 'enzyme'

import { UserDefinedField } from 'Common'

const onChange = jest.fn()

const fieldDefinition = {
  hidden: false,
  required: false,
  label: 'State',
  name: 'state',
  choices: undefined,
  id: 'state',
  hint: undefined,
  readOnly: false,
  type: 'extra'
}
const defaultProps = {
  fieldDefinition,
  onChange,
  value: ''
}

const mountWrapper = (props) => mount(<UserDefinedField {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

describe('where it does not have choices', () => {
  const field = { ...fieldDefinition, choices: undefined }

  it('should render a text input', () => {
    const wrapper = mountWrapper({ fieldDefinition: field })
    expect(wrapper.find('input[type="text"]').exists()).toBe(true)
  })
})

describe('where it has choices', () => {
  const field = { ...fieldDefinition, choices: ['pending', 'active'] }

  it('should render a select', () => {
    const wrapper = mountWrapper({ fieldDefinition: field })
    expect(wrapper.find('.pf-c-select').exists()).toBe(true)
  })
})
