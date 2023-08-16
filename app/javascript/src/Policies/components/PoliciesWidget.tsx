import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import * as actions from 'Policies/actions'
import { AddPolicyModal } from 'Policies/components/AddPolicyModal'
import { EditPolicyModal } from 'Policies/components/EditPolicyModal'
import { PolicyChain } from 'Policies/components/PolicyChain'
import { PolicyChainHiddenInput } from 'Policies/components/PolicyChainHiddenInput'
import { isPolicyChainChanged } from 'Policies/util'

import type { FunctionComponent } from 'react'
import type { Dispatch } from 'redux'
import type { ChainPolicy, IPoliciesActions, RegistryPolicy, State, UIState } from 'Policies/types'

import 'Policies/styles/policies.scss'

interface Props {
  registry: RegistryPolicy[];
  chain: ChainPolicy[];
  originalChain: ChainPolicy[];
  policyConfig: ChainPolicy;
  ui: UIState;
  boundActionCreators: IPoliciesActions;
}

const mapStateToProps = (state: State) => ({
  registry: state.registry,
  chain: state.chain,
  originalChain: state.originalChain,
  policyConfig: state.policyConfig,
  ui: state.ui
})

const mapDispatchToProps = (dispatch: Dispatch) => ({
  boundActionCreators: bindActionCreators(actions, dispatch)
})

const PolicyList: FunctionComponent<Props> = ({
  registry,
  chain,
  originalChain,
  policyConfig,
  ui,
  boundActionCreators
}) => {
  const chainActions = {
    openPolicyRegistry: boundActionCreators.openPolicyRegistry,
    editPolicy: boundActionCreators.openPolicyForm,
    sortPolicyChain: boundActionCreators.sortPolicyChain
  } as const
  const policyConfigActions = {
    submitPolicyConfig: boundActionCreators.submitPolicyForm,
    removePolicyFromChain: boundActionCreators.removePolicyFromChain,
    closePolicyConfig: boundActionCreators.closePolicyForm,
    updatePolicyConfig: boundActionCreators.updatePolicyConfig
  } as const
  const policyRegistryActions = {
    addPolicy: boundActionCreators.addPolicyFromRegistry,
    closePolicyRegistry: boundActionCreators.closePolicyRegistry
  } as const

  const buttonsFieldset = document.querySelector('[id^="edit_proxy_"] > fieldset.buttons')
  if (buttonsFieldset) {
    buttonsFieldset.classList.toggle('is-hidden', !ui.chain)
  }

  // HACK: enable the submit button after any change is made
  const submitButton = document.querySelector('#policies-button-sav')
  if (submitButton) {
    submitButton.toggleAttribute('disabled', !isPolicyChainChanged(chain, originalChain))
  }

  return (
    <>
      <div className="PoliciesWidget">
        <PolicyChain actions={chainActions} chain={chain} />
        <PolicyChainHiddenInput policies={chain} />
      </div>

      <EditPolicyModal
        actions={policyConfigActions}
        isOpen={ui.policyConfig}
        policy={policyConfig}
      />

      <AddPolicyModal
        actions={policyRegistryActions}
        isOpen={ui.registry}
        items={registry}
      />
    </>
  )
}

const PoliciesWidget = connect(
  mapStateToProps,
  mapDispatchToProps
)(PolicyList)

export type { Props }
export { PoliciesWidget as default, PolicyList }
