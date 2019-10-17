// @flow

import type { RegistryPolicy, ChainPolicy } from 'Policies/types'

type Policy = RegistryPolicy | ChainPolicy

function isNotApicastPolicy (policy: Policy): boolean {
  return (policy.name !== 'apicast')
}

export { isNotApicastPolicy }
