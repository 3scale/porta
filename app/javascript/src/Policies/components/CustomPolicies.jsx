// @flow

import * as React from 'react'
import {PolicyList} from 'Policies/components/PolicyList'
import 'Policies/styles/policies.scss'
import type {RegistryPolicy} from '../types/Policies'

const CustomPolicies = ({policies = []}: {policies: Array<RegistryPolicy>}): React.Node => {
  return (
    <section className="CustomPolicies">
      <header className='CustomPolicies-header'>
        <h2 className="CustomPolicies-title">Custom Policies</h2>
        <a className="CustomPolicies-addPolicy" href="/p/admin/registry/policies/new" >
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
