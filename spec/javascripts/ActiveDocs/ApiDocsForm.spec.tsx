import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { ApiDocsForm } from 'ActiveDocs/ApiDocsForm'
import { isSubmitDisabled } from 'utilities/test-utils'
import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'
import { NameInput } from 'ActiveDocs/components/NameInput'

import type { Props } from 'ActiveDocs/ApiDocsForm'

const mockMirror = {
  fromTextArea: () => {
    return {
      setValue: jest.fn(),
      on: jest.fn()
    }
  }
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
  },
  isUpdate: false
}

const mountWrapper = (props?: Partial<Props>) => mount(<ApiDocsForm {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})

it('should enable the submit button when all required inputs are filled', () => {
  const wrapper = mountWrapper()
  expect(isSubmitDisabled(wrapper)).toEqual(true)

  act(() => { 
    wrapper.find(ApiJsonSpecInput).props().setApiJsonSpec('{}')
    wrapper.find(NameInput).props().setName('')
  })
  
  expect(isSubmitDisabled(wrapper)).toEqual(true)

  act(() => { 
    wrapper.find(ApiJsonSpecInput).props().setApiJsonSpec('')
    wrapper.find(NameInput).props().setName('Banana')
  })
  
  expect(isSubmitDisabled(wrapper)).toEqual(true)
  act(() => { 
    wrapper.find(ApiJsonSpecInput).props().setApiJsonSpec('{}')
    wrapper.find(NameInput).props().setName('Banana')
  })
  
  expect(isSubmitDisabled(wrapper)).toEqual(false)
})

describe('When is new record', () => {
  const props = {
    isUpdate: false
  }

  it('should have all the inputs', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.exists('input[name="api_docs_service[name]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[system_name]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[published]"]')).toEqual(true)
    expect(wrapper.exists('textarea[name="api_docs_service[description]"]')).toEqual(true)
    expect(wrapper.exists('textarea[name="api_docs_service[body]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[skip_swagger_validations]"]')).toEqual(true)
    expect(wrapper.exists('input[name="_method"][type="hidden"][value="put"]')).toEqual(false)
  })

  it('should have SystemNameInput enabled', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find('input[id="api_docs_service_system_name"]').props().disabled).not.toBe(true)
  })

  it('should have the proper button', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find('button[type="submit"]').text()).toEqual('Create spec')
  })

  it('ServiceSelect should be hidden in product context', () => {
    const wrapper = mountWrapper({ ...props, collection: undefined })
    
    expect(wrapper.exists('input[name="api_docs_service[service_id]"]')).toEqual(false)
  })
  
  it('ServiceSelect should be displayed in audience context', () => {
    const wrapper = mountWrapper({ ...props, collection: [{ id: 1, name: 'myAPI' }] })

    expect(wrapper.exists('input[name="api_docs_service[service_id]"]')).toEqual(true)
  })
})

describe('When is update', () => {
  const updateProps = {
    name: 'Echo', 
    systemName: 'echo',
    published: true,
    serviceId: 2,
    collection: [
      { id: 2, name: 'API' },
      { id: 6, name: 'Test' }
    ],
    apiJsonSpec: '', //should we add an example spec somewhere?
    url: '/apiconfig/services/2/api_docs/1',
    isUpdate: true
  }

  it('should have all the inputs', () => {
    const wrapper = mountWrapper(updateProps)

    expect(wrapper.exists('input[name="api_docs_service[name]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[system_name]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[published]"]')).toEqual(true)
    expect(wrapper.exists('textarea[name="api_docs_service[description]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[service_id]"]')).toEqual(true)
    expect(wrapper.exists('textarea[name="api_docs_service[body]"]')).toEqual(true)
    expect(wrapper.exists('input[name="api_docs_service[skip_swagger_validations]"]')).toEqual(true)
    expect(wrapper.exists('input[name="_method"][type="hidden"][value="put"]')).toEqual(true)
  })

  it('should have SystemNameInput disabled', () => {
    const wrapper = mountWrapper(updateProps)

    expect(wrapper.find('input[id="api_docs_service_system_name"]').props().disabled).toBe(true)
  })

  it('should have the proper button', () => {
    const wrapper = mountWrapper(updateProps)

    expect(wrapper.find('button[type="submit"]').text()).toEqual('Update spec')
  })
})
