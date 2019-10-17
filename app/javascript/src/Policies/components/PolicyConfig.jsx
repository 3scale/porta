// @flow

import React from 'react'

import { PoliciesForm } from 'Policies/components/PoliciesForm'

import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

type Props = {
  visible: boolean,
  policy: ChainPolicy,
  actions: {
    submitPolicyConfig: (ChainPolicy) => ThunkAction,
    removePolicyFromChain: (ChainPolicy) => ThunkAction,
    closePolicyConfig: () => ThunkAction,
    updatePolicyConfig: (ChainPolicy) => UpdatePolicyConfigAction
  }
}

const PolicyConfig = ({visible, policy, actions}: Props) => {
  return (<PoliciesForm
    visible={visible}
    policy={policy}
    submitForm={actions.submitPolicyConfig}
    removePolicy={actions.removePolicyFromChain}
    closePolicyConfig={actions.closePolicyConfig}
    updatePolicy={actions.updatePolicyConfig}
  />)
}

export { PolicyConfig }
