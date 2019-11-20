// @flow

import * as React from 'react'

import type { RegistryPolicy } from 'Policies/types'

type Props = {
  policy: RegistryPolicy,
  title?: string,
  onClick: () => void
}

const PolicyTile = function ({policy, onClick, title = 'Edit this Policy'}: Props): React.Node {
  return (
    <article onClick={onClick} className="Policy-article" title={title}>
      <h3 className="Policy-name">{policy.humanName}</h3>
      <p className="Policy-version-and-summary">
        <span className="Policy-version">
          {policy.version}
        </span>
        {' - '}
        <span title={policy.summary} className="Policy-summary">
          {policy.summary}
        </span>
      </p>
    </article>
  )
}

export { PolicyTile }
