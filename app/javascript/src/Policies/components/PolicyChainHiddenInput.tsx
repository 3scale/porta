import * as React from 'react'

import type { ChainPolicy } from 'Policies/types'

type Props = {
  policies: ChainPolicy[]
};

const PolicyChainHiddenInput: React.FunctionComponent<Props> = ({ policies }) => {
  // TODO: Next iteration see if we can store the config as data field in Rails
  const parsedPolicies = policies.map(({ data, name, version, enabled }) => ({ configuration: data, name, version, enabled }))
  const data = JSON.stringify(parsedPolicies)

  return (
    <input
      type='hidden'
      id='proxy[policies_config]'
      name='proxy[policies_config]'
      value={data}
    />
  )
}

export { PolicyChainHiddenInput }
