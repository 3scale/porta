import { mount } from 'enzyme'

import { PolicyConfig } from 'Policies/components/PolicyConfig'

import type { Props } from 'Policies/components/PolicyConfig'
import type { ChainPolicy } from 'Policies/types'

const policyConfig: ChainPolicy = {
  uuid: '666',
  enabled: true,
  removable: true,
  name: 'caching',
  humanName: 'Caching policy',
  summary: 'Caching',
  description: ['Configures a cache for the authentication calls against the 3scale'],
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

const defaultProps = {
  policy: policyConfig,
  actions: {
    submitPolicyConfig: jest.fn(),
    removePolicyFromChain: jest.fn(),
    closePolicyConfig: jest.fn(),
    updatePolicyConfig: jest.fn()
  }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PolicyConfig {...{ ...defaultProps, ...props }} />)

it('should submit the form and call the submit action', () => {
  const policyConfigWrapper = mountWrapper()
  const policyConfigFormProps = policyConfigWrapper.find('.PolicyConfiguration-form').first().props()
  // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
  policyConfigFormProps.onSubmit!({ formData: {}, schema: {} } as any)
  expect(policyConfigWrapper.props().actions.submitPolicyConfig).toHaveBeenCalledTimes(1)
})

it('should display the policy\'s version and summary', () => {
  const policyConfigWrapper = mountWrapper()
  const versionAndSummary = policyConfigWrapper.find('.PolicyConfiguration-version-and-summary').text()

  expect(versionAndSummary).toContain(policyConfig.version)
  expect(versionAndSummary).toContain(policyConfig.summary)
})

it('should show the form unless it is apicast policy', () => {
  const policyConfigWrapper = mountWrapper()
  expect(policyConfigWrapper.exists('.PolicyConfiguration-form')).toEqual(true)

  const apicastPolicy = { ...policyConfig, name: 'apicast' }
  policyConfigWrapper.setProps({ policy: apicastPolicy })
  expect(policyConfigWrapper.exists('.PolicyConfiguration-form')).toEqual(false)
})

it('should allow enabling/disabling the policy unless it is apicast policy', () => {
  const policyConfigWrapper = mountWrapper()
  expect(policyConfigWrapper.exists('input[name="policy-enabled"]')).toEqual(true)

  const apicastPolicy = { ...policyConfig, name: 'apicast' }
  policyConfigWrapper.setProps({ policy: apicastPolicy })
  expect(policyConfigWrapper.exists('input[name="policy-enabled"]')).toEqual(false)
})

