import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { ApiDocsForm } from 'ActiveDocs/ApiDocsForm'
import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'
import { isSubmitDisabled } from 'utilities/test-utils'
import { NameInput } from 'ActiveDocs/components/NameInput'

import type { Props } from 'ActiveDocs/ApiDocsForm'

jest.mock('ActiveDocs/useCodeMirror')

const defaultProps: Props = {
  action: '',
  apiJsonSpec: '',
  collection: undefined,
  description: '',
  errors: {
    body: undefined,
    name: undefined,
    systemName: undefined
  },
  isUpdate: false,
  name: '',
  published: false,
  serviceId: undefined,
  skipSwaggerValidations: false,
  systemName: ''
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
    action: '/apiconfig/services/2/api_docs/1',
    apiJsonSpec: '',
    collection: [
      { id: 2, name: 'API' },
      { id: 6, name: 'Test' }
    ],
    isUpdate: true,
    name: 'Echo', 
    published: true,
    serviceId: 2,
    systemName: 'echo'
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
