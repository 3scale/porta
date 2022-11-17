import { mount } from 'enzyme'

import { UserDefinedField } from 'Common/components/UserDefinedField'

import type { Props } from 'Common/components/UserDefinedField'
import type { FieldDefinition } from 'Types'

const onChange = jest.fn()

const fieldDefinition: FieldDefinition = {
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
  value: '',
  validationErrors: undefined
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<UserDefinedField {...{ ...defaultProps, ...props }} />)

afterEach(() => onChange.mockReset())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

describe('where it does not have choices', () => {
  const field = { ...fieldDefinition, choices: undefined }

  it('should render a text input', () => {
    const wrapper = mountWrapper({ fieldDefinition: field })
    expect(wrapper.exists('input[type="text"]')).toEqual(true)
  })
})

describe('where it has choices', () => {
  const field = { ...fieldDefinition, choices: ['pending', 'active'] }

  it('should render a select', () => {
    const wrapper = mountWrapper({ fieldDefinition: field })
    expect(wrapper.exists('.pf-c-select')).toEqual(true)
  })
})
