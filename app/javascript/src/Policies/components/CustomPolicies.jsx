// @flow

import * as React from 'react'
import {PolicyList} from 'Policies/components/PolicyList'
import {parsePolicies, fromJson} from 'Policies/util'
import type {RawPolicy} from 'Policies/types/Policies'

import 'Policies/styles/policies.scss'

type Props = {
  rawPolicies: Array<RawPolicy>
}

const CustomPolicies = ({rawPolicies}: Props): React.Node => {
  const policies = parsePolicies(fromJson(rawPolicies))
  return (
    <section className="CustomPolicies">
      <header className='CustomPolicies-header'>
        <h2 className="CustomPolicies-title">Custom Policies</h2>
        <a className="CustomPolicies-addPolicy" ><i className="fa fa-plus-circle" /> Add new policy</a>
      </header>
      <PolicyList policies={policies} />
    </section>
  )
}

export {
  CustomPolicies
}
