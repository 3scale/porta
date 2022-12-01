import { mount } from 'enzyme'

import { ApiDocsForm } from 'ActiveDocs/ApiDocsForm'

import type { Props } from 'ActiveDocs/ApiDocsForm'

const mockMirror = {
  fromTextArea: jest.fn()
}

// @ts-expect-error Mocking CodeMirror
window.CodeMirror = mockMirror

const defaultProps: Props = {
  name: '',
  systemName: '',
  published: false,
  serviceId: undefined,
  collection: undefined,
  description: '',
  apiJsonSpec: '',
  skipSwaggerValidations: false,
  url: '',
  errors: {
    name: undefined,
    systemName: undefined,
    body: undefined
  }
}

const mountWrapper = (props?: Partial<Props>) => mount(<ApiDocsForm {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})

describe('all required inputs are filled', () => {
  const props = {
    name: 'Banana',
    apiJsonSpec: '{}'
  }

  it('should enable the submit button', () => {
    const wrapper = mountWrapper(props)
    const button = wrapper.find('button[type="submit"]')

    const isDisabled = button.prop('disabled')

    expect(isDisabled).toEqual(false)
  })
})

describe('not all required inputs are filled', () => {
  it('should disable the submit button when name is empty', () => {
    const wrapper = mountWrapper({ apiJsonSpec: '{}' })
    const button = wrapper.find('button[type="submit"]')

    const isDisabled = button.prop('disabled')

    expect(isDisabled).toEqual(true)
  })

  it('should disable the submit button when apiJsonSpec is empty', () => {
    const wrapper = mountWrapper({ name: 'Banana' })
    const button = wrapper.find('button[type="submit"]')

    const isDisabled = button.prop('disabled')

    expect(isDisabled).toEqual(true)
  })
})
