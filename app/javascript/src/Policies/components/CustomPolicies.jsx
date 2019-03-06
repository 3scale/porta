// @flow

import * as React from 'react'
import {PolicyList} from 'Policies/components/PolicyList'
import {parsePolicies, fromJson} from 'Policies/util'

import 'Policies/styles/policies.scss'

const CustomPolicies = ({jsonPolicies}: {jsonPolicies: string}): React.Node => {
  let policies = []
  try {
    policies = fromJson(jsonPolicies)
  } catch (err) {
    console.error('That doesn\'t look like a valid JSON')
  }
  return (
    <section className="CustomPolicies">
      <header className='CustomPolicies-header'>
        <h2 className="CustomPolicies-title">Custom Policies</h2>
        <a className="CustomPolicies-addPolicy" href="/p/admin/registry/policies/new" >
          <i className="fa fa-plus-circle" /> Add new policy
        </a>
      </header>
      <PolicyList policies={parsePolicies(policies)} />
    </section>
  )
}

export {
  CustomPolicies
}
