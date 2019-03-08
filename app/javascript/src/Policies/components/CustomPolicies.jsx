// @flow

import * as React from 'react'
import {PolicyList} from 'Policies/components/PolicyList'
import 'Policies/styles/policies.scss'
import type {ShallowPolicy} from 'Policies/types/Policies'

const CustomPolicies = ({policies = []}: {policies: Array<ShallowPolicy>}): React.Node => {
  const ADD_POLICY_HREF = '/p/admin/registry/policies/new'
  return (
    <section className="CustomPolicies">
      <header className='CustomPolicies-header'>
        <h2 className="CustomPolicies-title">Custom Policies</h2>
        <a className="CustomPolicies-addPolicy" href={ADD_POLICY_HREF} >
          <i className="fa fa-plus-circle" /> Add new policy
        </a>
      </header>
      <PolicyList policies={policies} />
    </section>
  )
}

export {
  CustomPolicies
}
