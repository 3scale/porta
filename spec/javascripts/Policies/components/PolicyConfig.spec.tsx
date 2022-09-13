import React from 'react'
import { mount } from 'enzyme'

import { PolicyConfig } from 'Policies/components/PolicyConfig'

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
      configuration: {
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
      data: {}
    }

    const props = {
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
    const { policyConfigWrapper } = setup()
    expect(policyConfigWrapper.find('section').hasClass('PolicyConfiguration')).toBe(true)
    expect(policyConfigWrapper.find('.PolicyConfiguration-name').text()).toBe('Caching policy')
    expect(policyConfigWrapper.find('.PolicyConfiguration-version-and-summary').text()).toBe('builtin - Caching')
    expect(policyConfigWrapper.find('.PolicyConfiguration-description').text())
      .toBe('Configures a cache for the authentication calls against the 3scale')
    expect(policyConfigWrapper.find('#policy-enabled').prop('checked')).toBe(true)
  })

  it('should render correctly the form with the schema given', () => {
    const { policyConfigWrapper } = setup()
    const policyConfigForm = policyConfigWrapper.find('.PolicyConfiguration-form').first()
    expect(policyConfigForm.find('#root_caching_type__description.field-description').text()).toBe('Caching mode')
    expect(policyConfigForm.find('#root_caching_type option').length).toBe(5)
  })

  it('should have a close button', () => {
    const { policyConfigWrapper, props } = setup()
    const closeConfigButton = policyConfigWrapper.find('HeaderButton')
    expect(closeConfigButton.find('.PolicyChain-addPolicy--cancel').exists()).toBe(true)
    expect(closeConfigButton.text()).toBe('Cancel')

    closeConfigButton.props().onClick()
    expect(props.actions.closePolicyConfig).toHaveBeenCalledTimes(1)
  })

  it('should have a remove button', () => {
    const { policyConfigWrapper, props } = setup()
    const removePolicyButton = policyConfigWrapper.find('.pf-c-button.pf-m-danger')
    expect(removePolicyButton.exists()).toBe(true)

    removePolicyButton.simulate('click')
    expect(props.actions.removePolicyFromChain).toHaveBeenCalledTimes(1)
  })

  it('should have a submit button', () => {
    const { policyConfigWrapper } = setup()
    const submitPolicyButton = policyConfigWrapper.find('.PolicyConfiguration-form .pf-c-button[type="submit"]')
    expect(submitPolicyButton.text()).toBe('Update Policy')
  })

  it('should submit the form and call the submit action', () => {
    const { policyConfigWrapper, props } = setup()
    const policyConfigFormProps = policyConfigWrapper.find('.PolicyConfiguration-form').first().props()
    policyConfigFormProps.onSubmit({ formData: {}, schema: {} })
    expect(props.actions.submitPolicyConfig).toHaveBeenCalledTimes(1)
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
      data: { },
      configuration: {}
    }

    const props = {
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
    const { policyConfigWrapper } = setup()
    expect(policyConfigWrapper.find('section').hasClass('PolicyConfiguration')).toBe(true)
    expect(policyConfigWrapper.find('.PolicyConfiguration-name').text()).toBe('APIcast')
    expect(policyConfigWrapper.find('.PolicyConfiguration-version-and-summary').text()).toBe('builtin - Main function...')
  })

  it('should hide the APIcast policy form', () => {
    const { policyConfigWrapper } = setup()

    expect(policyConfigWrapper.find('Form').exists()).toBe(false)
  })
})
