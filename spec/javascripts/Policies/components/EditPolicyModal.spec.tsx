import { mount } from 'enzyme'

import { EditPolicyModal } from 'Policies/components/EditPolicyModal'
import { isSubmitDisabled } from 'utilities/test-utils'

import type { ChainPolicy } from 'Policies/types'
import type { Props } from 'Policies/components/EditPolicyModal'

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

const defaultProps: Props = {
  isOpen: true,
  policy: policyConfig,
  actions: {
    submitPolicyConfig: jest.fn(),
    removePolicyFromChain: jest.fn(),
    closePolicyConfig: jest.fn(),
    updatePolicyConfig: jest.fn()
  }
}

beforeEach(() => {
  jest.clearAllMocks()
})

const mountWrapper = (props: Partial<Props> = {}) => mount(<EditPolicyModal {...{ ...defaultProps, ...props }} />)

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('#policy-edit-modal')).toEqual(true)
})

it('should display the policy\'s name', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-modal-box__header').text()).toEqual(policyConfig.humanName)
})

it('should have a close button', () => {
  const wrapper = mountWrapper()
  const { closePolicyConfig } = wrapper.props().actions
  expect(closePolicyConfig).toHaveBeenCalledTimes(0)

  wrapper.find('button[aria-label="Close"]').simulate('click')
  expect(closePolicyConfig).toHaveBeenCalledTimes(1)
})

it('should have a remove button when policy is removable', () => {
  const unremovablePolicy = { ...policyConfig, removable: false }
  const wrapper = mountWrapper({ policy: unremovablePolicy })

  expect(wrapper.exists('.pf-c-modal-box__footer .pf-m-danger')).toEqual(false)

  const removablePolicy = { ...policyConfig, removable: true }
  wrapper.setProps({ policy: removablePolicy })

  const { removePolicyFromChain } = wrapper.props().actions
  expect(removePolicyFromChain).toHaveBeenCalledTimes(0)

  wrapper.find('.pf-c-modal-box__footer .pf-m-danger').simulate('click')
  expect(removePolicyFromChain).toHaveBeenCalledTimes(1)
})

it('should have update and cancel buttons if not an apicast policy', () => {
  const wrapper = mountWrapper()

  expect(wrapper.find('.pf-c-modal-box__footer .pf-m-primary').text()).toEqual('Update Policy')
  expect(wrapper.find('.pf-c-modal-box__footer .pf-m-secondary').text()).toEqual('Cancel')

  const apicastPolicy = { ...policyConfig, name: 'apicast' }
  wrapper.setProps({ policy: apicastPolicy })

  expect(wrapper.exists('.pf-c-modal-box__footer .pf-m-secondary')).toEqual(false)
  expect(wrapper.find('.pf-c-modal-box__footer .pf-m-primary').text()).toEqual('Close')
})

it('should be able to update the policy', () => {
  const requestSubmit = jest.fn()
  jest.spyOn(document, 'forms', 'get')
    .mockReturnValueOnce({
    // @ts-expect-error - OK
      namedItem: () => ({
        requestSubmit
      })
    })

  const wrapper = mountWrapper()

  expect(isSubmitDisabled(wrapper)).toEqual(false)

  expect(requestSubmit).toHaveBeenCalledTimes(0)
  wrapper.find('button.pf-m-primary[type="submit"]').simulate('click')
  expect(requestSubmit).toHaveBeenCalledTimes(1)
})

it('should render a policy edit form', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('form#edit-policy-form')).toEqual(true)
})
