// @flow

import React from 'react'

import { PoliciesForm } from 'Policies/components/PoliciesForm'

import type { ThunkAction } from 'Policies/types/index'
import type { ChainPolicy } from 'Policies/types/Policies'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

type Props = {
  policy: ChainPolicy,
  actions: {
    submitPolicyConfig: (ChainPolicy) => ThunkAction,
    removePolicyFromChain: (ChainPolicy) => ThunkAction,
    closePolicyConfig: () => ThunkAction,
    updatePolicyConfig: (ChainPolicy) => UpdatePolicyConfigAction
  }
}

const PolicyConfig = ({policy, actions}: Props) => {
  return (<PoliciesForm
    policy={policy}
    submitForm={actions.submitPolicyConfig}
    removePolicy={actions.removePolicyFromChain}
    closePolicyConfig={actions.closePolicyConfig}
    updatePolicy={actions.updatePolicyConfig}
  />)
}

export { PolicyConfig }
