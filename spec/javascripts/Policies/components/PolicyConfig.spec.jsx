import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { PolicyConfig, PolicyForm } from 'Policies/components/PolicyConfig'

Enzyme.configure({ adapter: new Adapter() })

describe('PolicyConfig Component', () => {
  function setup () {
    const policyConfig = {
      id: '666',
      enabled: true,
      removable: true,
      name: 'caching',
      humanName: 'Caching policy',
      summary: 'Caching',
      description: 'Configures a cache for the authentication calls against the 3scale',
      version: 'builtin',
      $schema: 'http://apicast.io/policy-v1/schema#manifest#',
      schema: {
        properties: {
          caching_type: {
            oneOf: [
              {
                const: 'resilient',
                title: 'Authorize according to last request when backend is down.'
              },
              { const: 'strict',
                title: 'It only caches authorized calls.'
              },
              {
                const: 'allow',
                title: 'When backend is down, allow everything unless seen before and denied.'
              },
              {
                const: 'none',
                title: 'Disables caching.'
              }
            ],
            description: 'Caching mode',
            type: 'string'
          }
        },
        type: 'object'
      },
      configuration: {}
    }

    const props = {
      visible: true,
      policy: policyConfig,
      actions: {
        submitPolicyConfig: jest.fn(),
        removePolicyFromChain: jest.fn(),
        closePolicyConfig: jest.fn(),
        updatePolicyConfig: jest.fn()
      }
    }

    const policyConfigWrapper = mount(<PolicyConfig {...props} />)

    return {
      policyConfig,
      props,
      policyConfigWrapper
    }
  }

  it('should render self', () => {
    const {policyConfigWrapper} = setup()
    expect(policyConfigWrapper.find('section').hasClass('PolicyConfiguration')).toBe(true)

    const registryProps = policyConfigWrapper.props()
    expect(registryProps.visible).toBe(true)
    expect(policyConfigWrapper.find('.PolicyConfiguration-name').text()).toBe('Caching policy')
    expect(policyConfigWrapper.find('.PolicyConfiguration-version').text()).toBe('builtin')
    expect(policyConfigWrapper.find('.PolicyConfiguration-summary').text()).toBe('Caching')
    expect(policyConfigWrapper.find('.PolicyConfiguration-description').text())
      .toBe('Configures a cache for the authentication calls against the 3scale')
    expect(policyConfigWrapper.find('#policy-enabled').prop('checked')).toBe(true)
  })

  it('should render correctly the form with the schema given', () => {
    const {policyConfigWrapper} = setup()
    const policyConfigForm = policyConfigWrapper.find('.PolicyConfiguration-form').first()
    expect(policyConfigForm.find('#root_caching_type__description.field-description').text()).toBe('Caching mode')
    expect(policyConfigForm.find('#root_caching_type option').length).toBe(5)
  })

  it('should have a close button', () => {
    const {policyConfigWrapper, props} = setup()
    const closeConfigButton = policyConfigWrapper.find('.PolicyConfiguration-cancel')
    expect(closeConfigButton.text()).toBe(' Cancel')

    closeConfigButton.simulate('click')
    expect(props.actions.closePolicyConfig.mock.calls.length).toBe(1)
  })

  it('should have a remove button', () => {
    const {policyConfigWrapper, props} = setup()
    const removePolicyButton = policyConfigWrapper.find('.PolicyConfiguration-remove')
    expect(removePolicyButton.exists()).toBe(true)

    removePolicyButton.simulate('click')
    expect(props.actions.removePolicyFromChain.mock.calls.length).toBe(1)
  })

  it('should have a submit button', () => {
    const {policyConfigWrapper} = setup()
    const submitPolicyButton = policyConfigWrapper.find('button').first()
    expect(submitPolicyButton.text()).toBe('Update Policy')
  })

  it('should submit the form and call the submit action', () => {
    const {policyConfigWrapper, props} = setup()
    const policyConfigFormProps = policyConfigWrapper.find('.PolicyConfiguration-form').first().props()
    policyConfigFormProps.onSubmit({formData: {}, schema: {}})
    expect(props.actions.submitPolicyConfig.mock.calls.length).toBe(1)
  })
})

describe('PolicyConfig APIcast policy', () => {
  function setup () {
    const policyConfig = {
      uuid: '007',
      enabled: true,
      removable: false,
      name: 'apicast',
      humanName: 'APIcast',
      summary: 'Main function...',
      description: 'Main function...',
      version: 'builtin',
      $schema: 'http://apicast.io/policy-v1/schema#manifest#',
      schema: { },
      configuration: {}
    }

    const props = {
      visible: true,
      policy: policyConfig,
      actions: {
        submitPolicyConfig: jest.fn(),
        removePolicyFromChain: jest.fn(),
        closePolicyConfig: jest.fn(),
        updatePolicyConfig: jest.fn()
      }
    }

    const policyConfigWrapper = mount(<PolicyConfig {...props} />)

    return {
      policyConfig,
      props,
      policyConfigWrapper
    }
  }

  it('should display the APIcast policy name and summary', () => {
    const {policyConfigWrapper} = setup()
    expect(policyConfigWrapper.find('section').hasClass('PolicyConfiguration')).toBe(true)

    const registryProps = policyConfigWrapper.props()
    expect(registryProps.visible).toBe(true)
    expect(policyConfigWrapper.find('.PolicyConfiguration-name').text()).toBe('APIcast')
    expect(policyConfigWrapper.find('.PolicyConfiguration-summary').text()).toBe('Main function...')
  })

  it('should hide the APIcast policy form', () => {
    const {policyConfigWrapper} = setup()

    expect(policyConfigWrapper.find(PolicyForm).hasClass('hidden')).toBe(true)
  })
})

describe('PolicyForm', () => {
  function setup () {
    const props = {
      className: 'PolicyConfiguration-form',
      schema: {
        properties: {
          status: {
            type: 'integer',
            description: 'HTTP status code to be returned'
          }
        },
        type: 'object'
      },
      formData: {},
      onSubmit: jest.fn()
    }

    const policyFormWrapper = mount(<PolicyForm {...props} />)

    return {
      props,
      policyFormWrapper
    }
  }

  it('should clear the errors when loading a different schema', () => {
    const {policyFormWrapper} = setup()
    const statusInput = policyFormWrapper.find('input')
    statusInput.simulate('change', { target: { value: 'NaN' } })
    const instance = policyFormWrapper.instance()
    const event = {preventDefault: jest.fn()}

    instance.onSubmit(event)
    expect(policyFormWrapper.state().errors.length).toBe(1)

    policyFormWrapper.setProps({schema: {}})
    expect(policyFormWrapper.state().errors.length).toBe(0)
  })
})
