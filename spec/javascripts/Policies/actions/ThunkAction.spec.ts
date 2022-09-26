import * as ThunkActions from 'Policies/actions/ThunkActions'
import * as PolicyRegistry from 'Policies/actions/PolicyRegistry'
import * as PolicyChain from 'Policies/actions/PolicyChain'
import * as UISettings from 'Policies/actions/UISettings'
import * as PolicyConfigActions from 'Policies/actions/PolicyConfig'
import { PolicyConfig, RegistryPolicy, ChainPolicy } from 'Policies/types'

const policyConfig: PolicyConfig = {
  name: 'name',
  configuration: {},
  version: '1',
  enabled: false
}

const registryPolicy: RegistryPolicy = {
  name: 'name',
  configuration: {},
  version: '1',
  $schema: '{}',
  description: ['description'],
  summary: 'summary',
  data: undefined,
  humanName: 'Mr. Human'
}

const chainPolicy: ChainPolicy = {
  ...registryPolicy,
  uuid: '123',
  enabled: false,
  removable: true
}

const dispatch = jest.fn()

afterEach(() => { jest.clearAllMocks() })

it('#loadSavedPolicies should work', () => {
  const policyConfigs = [policyConfig]
  const registryPolicies = [registryPolicy]
  ThunkActions.loadSavedPolicies(policyConfigs, registryPolicies)(dispatch, jest.fn())

  expect(dispatch).toHaveBeenCalledTimes(2)
  expect(dispatch).toHaveBeenNthCalledWith(1, { payload: registryPolicies, type: 'LOAD_REGISTRY_SUCCESS' })
  expect(dispatch).toHaveBeenNthCalledWith(2, { policiesConfig: policyConfigs, type: 'LOAD_CHAIN' })
})

it('#populateChainFromConfigs should fetch registry and proxy policies', () => {
  const expected = `
    Array [
      Array [
        Object {
          "@@redux-api-middleware/RSAA": Object {
            "credentials": "same-origin",
            "endpoint": "/admin/api/policies.json",
            "method": "GET",
            "types": Array [
              Object {
                "type": "FETCH_REGISTRY_REQUEST",
              },
              Object {
                "type": "FETCH_REGISTRY_SUCCESS",
              },
              Object {
                "type": "FETCH_REGISTRY_ERROR",
              },
            ],
          },
        },
      ],
      Array [
        Object {
          "@@redux-api-middleware/RSAA": Object {
            "credentials": "same-origin",
            "endpoint": "/admin/api/services/serviceId/proxy/policies.json",
            "method": "GET",
            "types": Array [
              Object {
                "type": "FETCH_CHAIN_REQUEST",
              },
              Object {
                "type": "FETCH_CHAIN_SUCCESS",
              },
              Object {
                "type": "FETCH_CHAIN_ERROR",
              },
            ],
          },
        },
      ],
    ]
  `
  const fetchRegistry = jest.spyOn(PolicyRegistry, 'fetchRegistry')
  const fetchChain = jest.spyOn(PolicyChain, 'fetchChain')

  ThunkActions.populateChainFromConfigs('serviceId')(dispatch, jest.fn())
  expect(dispatch.mock.calls).toMatchInlineSnapshot(expected)

  dispatch.mockClear()
  ThunkActions.populateChainFromConfigs('serviceId', [policyConfig])(dispatch, jest.fn())
  expect(dispatch.mock.calls).toMatchInlineSnapshot(expected)

  dispatch.mockClear()
  ThunkActions.populateChainFromConfigs('serviceId', undefined, [registryPolicy])(dispatch, jest.fn())
  expect(dispatch.mock.calls).toMatchInlineSnapshot(expected)

  expect(fetchRegistry).toHaveBeenCalledTimes(3)
  expect(fetchChain).toHaveBeenCalledTimes(3)
})

it('#populateChainFromConfigs should call loadSavedPolicies', () => {
  const loadSavedPolicies = jest.spyOn(ThunkActions, 'loadSavedPolicies')
  ThunkActions.populateChainFromConfigs('serviceId', [policyConfig], [registryPolicy])(dispatch, jest.fn())

  expect(dispatch).toHaveBeenCalledTimes(1)
  expect(loadSavedPolicies).toHaveBeenCalledTimes(1)
})

it('#addPolicyFromRegistry should dispatch the appropriate actions', () => {
  const addPolicyToChain = jest.spyOn(PolicyChain, 'addPolicyToChain')
  const uiComponentTransition = jest.spyOn(UISettings, 'uiComponentTransition')
  ThunkActions.addPolicyFromRegistry(registryPolicy)(dispatch, jest.fn())

  expect(addPolicyToChain).toHaveBeenCalledTimes(1)
  expect(uiComponentTransition).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledTimes(2)
})

it('#removePolicyFromChain should dispatch the appropriate actions', () => {
  const removePolicy = jest.spyOn(PolicyChain, 'removePolicy')
  const uiComponentTransition = jest.spyOn(UISettings, 'uiComponentTransition')
  ThunkActions.removePolicyFromChain(chainPolicy)(dispatch, jest.fn())

  expect(removePolicy).toHaveBeenCalledTimes(1)
  expect(uiComponentTransition).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledTimes(2)
})

it('#openPolicyRegistry should dispatch the appropriate actions', () => {
  const uiComponentTransition = jest.spyOn(UISettings, 'uiComponentTransition')
  ThunkActions.openPolicyRegistry()(dispatch, jest.fn())

  expect(uiComponentTransition).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledWith({
    hide: 'chain',
    show: 'registry',
    type: 'UI_COMPONENT_TRANSITION'
  })
})

it('#closePolicyRegistry should dispatch the appropriate actions', () => {
  const uiComponentTransition = jest.spyOn(UISettings, 'uiComponentTransition')
  ThunkActions.closePolicyRegistry()(dispatch, jest.fn())

  expect(uiComponentTransition).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledWith({
    hide: 'registry',
    show: 'chain',
    type: 'UI_COMPONENT_TRANSITION'
  })
})

it('#openPolicyForm should dispatch the appropriate actions', () => {
  const updatePolicyConfig = jest.spyOn(PolicyConfigActions, 'updatePolicyConfig')
  const uiComponentTransition = jest.spyOn(UISettings, 'uiComponentTransition')
  ThunkActions.openPolicyForm(chainPolicy)(dispatch, jest.fn())

  expect(updatePolicyConfig).toHaveBeenCalledTimes(1)
  expect(uiComponentTransition).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledTimes(2)
  expect(dispatch).toHaveBeenLastCalledWith({
    hide: 'chain',
    show: 'policyConfig',
    type: 'UI_COMPONENT_TRANSITION'
  })
})

it('#submitPolicyForm should dispatch the appropriate actions', () => {
  const updatePolicyInChain = jest.spyOn(PolicyChain, 'updatePolicyInChain')
  const closePolicyForm = jest.spyOn(ThunkActions, 'closePolicyForm')
  ThunkActions.submitPolicyForm(chainPolicy)(dispatch, jest.fn())

  expect(updatePolicyInChain).toHaveBeenCalledTimes(1)
  expect(closePolicyForm).toHaveBeenCalledTimes(1)
  expect(dispatch).toHaveBeenCalledTimes(2)
})

it('#closePolicyForm should dispatch the appropriate actions', () => {
  const uiComponentTransition = jest.spyOn(UISettings, 'uiComponentTransition')
  ThunkActions.closePolicyForm()(dispatch, jest.fn())

  expect(uiComponentTransition).toHaveBeenCalledWith({ hide: 'policyConfig', show: 'chain' })
  expect(dispatch).toHaveBeenCalledTimes(1)
})
