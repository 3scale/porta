import { bindActionCreators } from 'redux'
import * as actions from 'Policies/actions'
import { PolicyConfig } from 'Policies/components/PolicyConfig'
import { PolicyChain } from 'Policies/components/PolicyChain'
import { PolicyRegistry } from 'Policies/components/PolicyRegistry'
import { PolicyChainHiddenInput } from 'Policies/components/PolicyChainHiddenInput'
import { connect } from 'react-redux'
import { isPolicyChainChanged } from 'Policies/util'

import type { Dispatch } from 'redux'
import type { ChainPolicy, IPoliciesActions, RegistryPolicy, State, UIState } from 'Policies/types'

type Props = {
  registry: Array<RegistryPolicy>,
  chain: Array<ChainPolicy>,
  originalChain: Array<ChainPolicy>,
  policyConfig: ChainPolicy,
  ui: UIState,
  boundActionCreators: IPoliciesActions
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

const PolicyList = ({
  registry,
  chain,
  originalChain,
  policyConfig,
  ui,
  boundActionCreators
}: Props) => {
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
    <div className="PoliciesWidget">
      {ui.chain && <PolicyChain actions={chainActions} chain={chain} />}
      {ui.registry && <PolicyRegistry actions={policyRegistryActions} items={registry} />}
      {ui.policyConfig && <PolicyConfig actions={policyConfigActions} policy={policyConfig} />}
      <PolicyChainHiddenInput policies={chain} />
    </div>
  )
}

const PoliciesWidget = connect(
  mapStateToProps,
  mapDispatchToProps
)(PolicyList)

export default PoliciesWidget
export { PolicyList, Props }
