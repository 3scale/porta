import * as PolicyRegistry from 'Policies/actions/PolicyRegistry'

import type { RegistryPolicy } from 'Policies/types'

it('#loadRegistrySuccess should create an action', () => {
  const payload: RegistryPolicy[] = []
  expect(PolicyRegistry.loadRegistrySuccess(payload)).toEqual({ type: 'LOAD_REGISTRY_SUCCESS', payload })
})

it('#fetchRegistry should create an action to use the redux api middleware', () => {
  expect(PolicyRegistry.fetchRegistry()).toMatchInlineSnapshot(`
    {
      "@@redux-api-middleware/RSAA": {
        "credentials": "same-origin",
        "endpoint": "/admin/api/policies.json",
        "method": "GET",
        "types": [
          {
            "type": "FETCH_REGISTRY_REQUEST",
          },
          {
            "type": "FETCH_REGISTRY_SUCCESS",
          },
          {
            "type": "FETCH_REGISTRY_ERROR",
          },
        ],
      },
    }
  `)
})
