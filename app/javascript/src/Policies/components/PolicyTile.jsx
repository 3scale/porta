// @flow

import * as React from 'react'
import type { RegistryPolicy } from 'Policies/types/Policies'

type Props = {
  policy: RegistryPolicy,
  title?: string,
  edit: any // Any Fn, PolicyChain generates a ThunkAction while PolicyList navigates outside
}

const PolicyTile = function ({policy, edit, title = 'Edit this Policy'}: Props): React.Node {
  return (
    <article onClick={edit} className="Policy-article" title={title}>
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
